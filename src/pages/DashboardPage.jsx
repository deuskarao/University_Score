import { useMemo } from "react";
import { useTheme } from "../theme/ThemeProvider";
import { useWindowSize } from "../components/shared.jsx";
import KpiCard from "../components/KpiCard";
import GpaTrendChart from "../components/GpaTrendChart";
import CreditDonutChart from "../components/CreditDonutChart";
import { hesaplaDönemOrt, hesaplaHarf } from "../hooks/useDersler";

function SectionCard({ title, children }) {
  const { tokens } = useTheme();
  return (
    <div style={{ background: tokens.card, border: `1px solid ${tokens.border}`, borderRadius: 16, padding: "22px 24px", boxShadow: tokens.shadowSm, transition: "box-shadow 0.2s ease" }}>
      <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 18 }}>
        <div style={{ width: 3, height: 14, background: `linear-gradient(180deg, ${tokens.primary}, ${tokens.primaryHover})`, borderRadius: 2 }} />
        <div style={{ fontSize: 13.5, fontWeight: 700, color: tokens.textPrimary, letterSpacing: -0.1 }}>{title}</div>
      </div>
      {children}
    </div>
  );
}

export default function DashboardPage({ dersler, stats, harfNotlari, bolum }) {
  const { tokens } = useTheme();
  const w = useWindowSize();

  const gpaTrendData = useMemo(() => {
    const aktifDonemler = new Set(dersler.filter((d) => d.vize > 0 || d.odev > 0 || d.proje > 0 || d.final > 0 || d.harfNotu).map((d) => d.donem));
    const donemMap = new Map();
    
    dersler.forEach((d) => {
      if (!aktifDonemler.has(d.donem)) return;
      const ort = hesaplaDönemOrt(d);
      const harf = d.harfNotu ? (harfNotlari.find((h) => h.harf === d.harfNotu) || { harf: d.harfNotu, katsayi: 0 }) : hesaplaHarf(ort, harfNotlari);
      if (harf.harf === "EK") return;
      
      if (!donemMap.has(d.donem)) donemMap.set(d.donem, { katsayiKredi: 0, kredi: 0 });
      const entry = donemMap.get(d.donem);
      entry.katsayiKredi += harf.katsayi * d.kredi;
      entry.kredi += d.kredi;
    });

    const sonDonem = bolum?.toplamDonem || Math.max(1, ...Array.from(donemMap.keys(), Number), ...dersler.map((d) => d.donem));
    return Array.from({ length: sonDonem }, (_, i) => i + 1).map((donem) => {
      const entry = donemMap.get(donem);
      return { label: `D${donem}`, value: entry && entry.kredi ? entry.katsayiKredi / entry.kredi : 0 };
    });
  }, [dersler, harfNotlari, bolum]);

  const { riskli, yaklasan, guclu, enYuksek, enDusuk } = stats;

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 20 }}>
      <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(200px, 1fr))", gap: 16 }}>
        <KpiCard label="GPA" value={stats.gano} suffix="/ 4.00" accent={tokens.primary} iconColor={tokens.primary} icon={<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="M22 10v6M2 10l10-5 10 5-10 5z"/><path d="M6 12v5c0 1.66 2.69 3 6 3s6-1.34 6-3v-5"/></svg>} />
        <KpiCard label="Toplam Ders" value={stats.toplam} iconColor={tokens.textSecondary} icon={<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>} />
        <KpiCard label="Geçilen Dersler" value={stats.gecen} accent={tokens.success} iconColor={tokens.success} icon={<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>} />
        <KpiCard label="Kalan Kredi" value={stats.kalanKredi} iconColor={tokens.warning} icon={<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>} />
      </div>
      <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(300px, 1fr))", gap: 16 }}>
        <SectionCard title="GPA Trendi"><GpaTrendChart data={gpaTrendData} /></SectionCard>
        <SectionCard title="Kredi Dağılımı"><CreditDonutChart gecenKredi={stats.gecenKredi} kalanKredi={stats.kalanKredi} /></SectionCard>
      </div>
      <SectionCard title="Akademik Özet">
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(180px, 1fr))", gap: 16 }}>
          <SummaryItem label="En Yüksek Not" value={enYuksek ? `${enYuksek.ad}` : "—"} sub={enYuksek ? `${enYuksek.ort.toFixed(1)}` : null} color={tokens.success} />
          <SummaryItem label="En Düşük Not" value={enDusuk ? `${enDusuk.ad}` : "—"} sub={enDusuk ? `${enDusuk.ort.toFixed(1)}` : null} color={tokens.danger} />
          <SummaryItem label="Bu Dönem GPA" value={stats.secilDonemGano ?? "—"} color={tokens.primary} />
          <SummaryItem label="Tamamlanma Oranı" value={`${stats.tamamlanmaOrani}%`} color={tokens.warning} />
        </div>
      </SectionCard>
      <SectionCard title="Performans Analizi">
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(220px, 1fr))", gap: 16 }}>
          <PerformanceList title="Riskli Dersler" items={riskli} tone="danger" emptyText="Riskli ders yok" />
          <PerformanceList title="Geçmeye Yakın" items={yaklasan} tone="warning" emptyText="Bu kategoride ders yok" />
          <PerformanceList title="Güçlü Dersler" items={guclu} tone="success" emptyText="Henüz veri yok" />
        </div>
      </SectionCard>
    </div>
  );
}

function SummaryItem({ label, value, sub, color }) {
  const { tokens } = useTheme();
  return (
    <div>
      <div style={{ fontSize: 11, color: tokens.muted, fontWeight: 600, textTransform: "uppercase", letterSpacing: 0.5, marginBottom: 6 }}>{label}</div>
      <div style={{ fontSize: 15, fontWeight: 700, color: tokens.textPrimary }}>{value}</div>
      {sub && <div style={{ fontSize: 13, fontWeight: 700, color, marginTop: 2 }}>{sub}</div>}
    </div>
  );
}

function PerformanceList({ title, items, tone, emptyText }) {
  const { tokens } = useTheme();
  const color = tokens[tone];
  return (
    <div>
      <div style={{ fontSize: 12, fontWeight: 700, color, marginBottom: 10 }}>{title}</div>
      {items.length === 0 ? (
        <div style={{ fontSize: 12, color: tokens.muted }}>{emptyText}</div>
      ) : (
        <div style={{ display: "flex", flexDirection: "column", gap: 6 }}>
          {items.slice(0, 5).map((d) => (
            <div key={d.id} style={{ display: "flex", justifyContent: "space-between", fontSize: 12.5, padding: "6px 8px", borderRadius: 8, background: color + "12" }}>
              <span style={{ color: tokens.textPrimary, fontWeight: 500 }}>{d.ad}</span>
              <span style={{ color, fontWeight: 700 }}>{d.ort.toFixed(1)}</span>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
