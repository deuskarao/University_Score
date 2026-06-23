import { useState, useEffect } from "react";
import { useTheme } from "../theme/ThemeProvider";
import { useAuth } from "../context/AuthContext";
import { supabase } from "../lib/supabase";
import { Overlay, useInputStyle } from "../components/shared.jsx";

function downloadFile(filename, content, mime) {
  const blob = new Blob([content], { type: mime });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url; a.download = filename;
  document.body.appendChild(a); a.click();
  document.body.removeChild(a); URL.revokeObjectURL(url);
}

export default function SettingsPage({ dersler, stats, bolum }) {
  const { tokens, mode, setMode } = useTheme();
  const { user, profile, logout, updateProfile } = useAuth();
  const [notifEmail, setNotifEmail] = useState(true);
  const [notifGrade, setNotifGrade] = useState(true);
  const [facultyName, setFacultyName] = useState(null);
  const [universityName, setUniversityName] = useState(null);
  const [isUpdatingDept, setIsUpdatingDept] = useState(false);
  const [usernameModal, setUsernameModal] = useState(false);
  const [usernameInput, setUsernameInput] = useState("");
  const inputStyle = useInputStyle();

  useEffect(() => {
    async function loadOrgInfo() {
      const fetches = [];

      // Fakülte: önce profile.faculty_id'den dene, yoksa faculty_departments üzerinden bul
      if (profile?.faculty_id) {
        fetches.push(
          supabase.from("faculties").select("ad").eq("id", profile.faculty_id).maybeSingle()
            .then(({ data }) => { if (data) setFacultyName(data.ad); })
        );
      } else if (profile?.department_id) {
        fetches.push(
          supabase
            .from("faculty_departments")
            .select("faculties!inner(ad)")
            .eq("department_id", profile.department_id)
            .maybeSingle()
            .then(({ data }) => {
              if (data?.faculties) setFacultyName(data.faculties.ad);
              else {
                // department_slug üzerinden dene
                supabase.from("departments").select("slug").eq("id", profile.department_id).maybeSingle()
                  .then(({ data: dept }) => {
                    if (!dept) return;
                    supabase.from("faculty_departments").select("faculties!inner(ad)")
                      .eq("department_slug", dept.slug).maybeSingle()
                      .then(({ data: fd }) => { if (fd?.faculties) setFacultyName(fd.faculties.ad); });
                  });
              }
            })
        );
      }

      // Üniversite: profile.university_id'den çek
      if (profile?.university_id) {
        fetches.push(
          supabase.from("universities").select("ad").eq("id", profile.university_id).maybeSingle()
            .then(({ data }) => { if (data) setUniversityName(data.ad); })
        );
      }

      await Promise.all(fetches);
    }
    loadOrgInfo();
  }, [profile?.faculty_id, profile?.department_id, profile?.university_id]);

  async function handleThemeChange(m) {
    setMode(m);
    try { await supabase.from("profiles").update({ theme_preference: m }).eq("id", user.id); } catch {}
  }

  async function handleResetDepartment() {
    if (!confirm("Bölümünüzü değiştirmek istediğinize emin misiniz?")) return;
    setIsUpdatingDept(true);
    try {
      await updateProfile({ department_id: null, faculty_id: null, university_id: null });
    } catch (e) {
      console.error(e);
      alert("Hata oluştu.");
      setIsUpdatingDept(false);
    }
  }

  function openUsernameModal() {
    setUsernameInput(profile?.username || "");
    setUsernameModal(true);
  }

  async function saveUsername() {
    if (usernameInput && !/^[a-zA-Z0-9_.-]+$/.test(usernameInput)) {
      alert("Lütfen geçerli bir kullanıcı adı girin (Sadece harf, rakam, alt çizgi, nokta).");
      return;
    }
    try {
      await updateProfile({ username: usernameInput || null });
      setUsernameModal(false);
    } catch (err) {
      alert("Bu kullanıcı adı zaten alınmış veya geçersiz!");
    }
  }

  function exportJSON() {
    const payload = { bolum: bolum?.ad, exportedAt: new Date().toISOString(), stats, dersler };
    downloadFile(`unipulse-export-${Date.now()}.json`, JSON.stringify(payload, null, 2), "application/json");
  }
  function exportCSV() {
    const header = "Ders,Dönem,Kredi,Vize,Ödev,Proje,Final\n";
    const rows = dersler.map(d => `${d.ad},${d.donem},${d.kredi},${d.vize},${d.odev},${d.proje},${d.final}`).join("\n");
    downloadFile(`unipulse-export-${Date.now()}.csv`, header + rows, "text/csv");
  }

  // Kullanıcı baş harfi + renk
  const initials = (profile?.full_name || user?.email || "?")[0]?.toUpperCase() || "?";

  const infoItems = [
    { icon: "🏛️", label: "Üniversite", value: universityName },
    { icon: "🎓", label: "Fakülte", value: facultyName },
    { icon: "📚", label: "Bölüm", value: bolum?.ad || profile?.department_id ? (bolum?.ad || "Yükleniyor…") : null },
  ];

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 24 }}>

      {/* ── Profil Kartı ── */}
      <div style={{
        background: `linear-gradient(135deg, ${tokens.primary}18 0%, ${tokens.card} 60%)`,
        border: `1px solid ${tokens.primary}30`,
        borderRadius: 20, padding: "28px 28px 24px",
        boxShadow: `0 0 40px ${tokens.primary}10`,
        position: "relative", overflow: "hidden",
      }}>
        {/* Dekoratif arka plan */}
        <div style={{ position: "absolute", top: -60, right: -60, width: 200, height: 200, borderRadius: "50%", background: tokens.primary + "0a", pointerEvents: "none" }} />
        <div style={{ position: "absolute", bottom: -40, left: -40, width: 150, height: 150, borderRadius: "50%", background: tokens.primary + "08", pointerEvents: "none" }} />

        <div style={{ display: "flex", alignItems: "center", gap: 20, position: "relative", zIndex: 1 }}>
          {/* Avatar */}
          <div style={{
            width: 72, height: 72, borderRadius: 20, flexShrink: 0,
            background: `linear-gradient(135deg, ${tokens.primary}, ${tokens.primary}aa)`,
            display: "flex", alignItems: "center", justifyContent: "center",
            fontSize: 28, fontWeight: 800, color: "#fff",
            boxShadow: `0 8px 24px ${tokens.primary}40`,
            border: `3px solid ${tokens.primary}30`,
          }}>{initials}</div>

          {/* Ad + email */}
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ display: "flex", alignItems: "center", gap: 10, flexWrap: "wrap" }}>
              <div style={{ fontSize: 22, fontWeight: 800, color: tokens.textPrimary, letterSpacing: -0.5 }}>
                {profile?.full_name || "Kullanıcı"}
              </div>
              <button onClick={openUsernameModal} style={{ fontSize: 13, fontWeight: 700, color: tokens.primary, background: tokens.primary + "15", padding: "4px 10px", borderRadius: 8, border: "none", cursor: "pointer", transition: "all 0.2s" }} onMouseEnter={(e) => e.target.style.background = tokens.primary + "25"} onMouseLeave={(e) => e.target.style.background = tokens.primary + "15"}>
                {profile?.username ? `@${profile.username}` : "+ Kullanıcı Adı Ekle"}
              </button>
            </div>
            <div style={{ fontSize: 13, color: tokens.muted, marginTop: 4 }}>{user?.email}</div>
            <div style={{ display: "flex", gap: 8, marginTop: 10, flexWrap: "wrap" }}>
              {infoItems.filter(i => i.value).map(item => (
                <span key={item.label} style={{
                  display: "inline-flex", alignItems: "center", gap: 5,
                  padding: "4px 10px", borderRadius: 99,
                  background: tokens.primary + "15", border: `1px solid ${tokens.primary}25`,
                  fontSize: 11.5, fontWeight: 600, color: tokens.primary,
                }}>
                  {item.icon} {item.value}
                </span>
              ))}
            </div>
          </div>

          {/* Çıkış */}
          <button onClick={logout} style={{
            display: "flex", alignItems: "center", gap: 7, flexShrink: 0,
            padding: "9px 16px", borderRadius: 12,
            border: `1px solid ${tokens.danger}35`,
            background: tokens.danger + "10",
            color: tokens.danger, fontWeight: 600, fontSize: 12.5,
            cursor: "pointer", transition: "all 0.2s", fontFamily: "inherit",
          }}
            onMouseEnter={e => { e.currentTarget.style.background = tokens.danger + "20"; e.currentTarget.style.borderColor = tokens.danger + "55"; }}
            onMouseLeave={e => { e.currentTarget.style.background = tokens.danger + "10"; e.currentTarget.style.borderColor = tokens.danger + "35"; }}
          >
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
              <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/>
            </svg>
            Çıkış Yap
          </button>
        </div>
      </div>

      {/* ── Alt Grid ── */}
      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: 16 }}>

        {/* Bildirimler */}
        <SettingCard
          tokens={tokens}
          icon={<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>}
          title="Bildirimler"
        >
          <ToggleRow
            tokens={tokens}
            label="E-posta Bildirimleri"
            sub="Önemli güncellemeler"
            checked={notifEmail}
            onChange={setNotifEmail}
          />
          <ToggleRow
            tokens={tokens}
            label="Not Güncellemeleri"
            sub="Not eklenince bildirim al"
            checked={notifGrade}
            onChange={setNotifGrade}
          />
        </SettingCard>

        {/* Tema */}
        <SettingCard
          tokens={tokens}
          icon={<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="5"/><line x1="12" y1="1" x2="12" y2="3"/><line x1="12" y1="21" x2="12" y2="23"/><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/><line x1="1" y1="12" x2="3" y2="12"/><line x1="21" y1="12" x2="23" y2="12"/><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"/></svg>}
          title="Görünüm"
        >
          <div style={{ display: "flex", gap: 0, borderRadius: 12, overflow: "hidden", border: `1px solid ${tokens.border}`, marginTop: 4 }}>
            {[
              { id: "light", label: "☀️ Açık" },
              { id: "dark", label: "🌙 Koyu" },
            ].map(({ id, label }) => (
              <button key={id} onClick={() => handleThemeChange(id)} style={{
                flex: 1, padding: "10px 0", border: "none", fontFamily: "inherit",
                background: mode === id ? tokens.primary : "transparent",
                color: mode === id ? "#fff" : tokens.muted,
                fontWeight: 700, fontSize: 12.5, cursor: "pointer",
                transition: "all 0.2s",
              }}>{label}</button>
            ))}
          </div>
          <div style={{ marginTop: 12, padding: "10px 14px", borderRadius: 10, background: tokens.surface, border: `1px solid ${tokens.border}` }}>
            <div style={{ fontSize: 11, color: tokens.muted, fontWeight: 600, textTransform: "uppercase", letterSpacing: 0.5, marginBottom: 4 }}>Aktif Tema</div>
            <div style={{ fontSize: 13, fontWeight: 700, color: tokens.textPrimary }}>{mode === "dark" ? "🌙 Koyu Mod" : "☀️ Açık Mod"}</div>
          </div>
        </SettingCard>

        {/* Veri Dışa Aktarma */}
        <SettingCard
          tokens={tokens}
          icon={<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>}
          title="Veri Dışa Aktarma"
        >
          <p style={{ fontSize: 12, color: tokens.muted, margin: "0 0 12px", lineHeight: 1.5 }}>
            Tüm ders ve not verilerini indir.
          </p>
          <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
            <ExportButton onClick={exportJSON} tokens={tokens} color="#F59E0B" icon="{ }">
              JSON İndir
            </ExportButton>
            <ExportButton onClick={exportCSV} tokens={tokens} color="#10B981" icon="⊞">
              CSV İndir
            </ExportButton>
          </div>
          {dersler?.length > 0 && (
            <div style={{ marginTop: 12, padding: "8px 12px", borderRadius: 8, background: tokens.surface, border: `1px solid ${tokens.border}`, fontSize: 11, color: tokens.muted }}>
              📊 {dersler.length} ders · {stats?.totalKredi || 0} toplam kredi
            </div>
          )}
        </SettingCard>
      </div>

      {/* ── Hesap Detayları ── */}
      <div style={{
        background: tokens.card, border: `1px solid ${tokens.border}`,
        borderRadius: 16, overflow: "hidden",
      }}>
        <div style={{ padding: "16px 22px", borderBottom: `1px solid ${tokens.border}`, display: "flex", alignItems: "center", justifyContent: "space-between" }}>
          <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
            <div style={{ width: 28, height: 28, borderRadius: 8, background: tokens.primary + "18", display: "flex", alignItems: "center", justifyContent: "center", color: tokens.primary }}>
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
            </div>
            <span style={{ fontSize: 13, fontWeight: 700, color: tokens.textPrimary }}>Hesap Bilgileri</span>
          </div>
          <button 
            onClick={handleResetDepartment}
            disabled={isUpdatingDept}
            style={{ 
              padding: "7px 14px", borderRadius: 8, background: tokens.primary + "12", 
              border: `1px solid ${tokens.primary}40`, color: tokens.primary, 
              fontSize: 12, fontWeight: 600, cursor: isUpdatingDept ? "wait" : "pointer",
              transition: "all 0.2s"
            }}>
            {isUpdatingDept ? "Güncelleniyor..." : "Bölümü Değiştir"}
          </button>
        </div>
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(200px, 1fr))" }}>
          {[
            { label: "Üniversite", value: universityName, icon: "🏛️" },
            { label: "Fakülte", value: facultyName, icon: "🎓" },
            { label: "Bölüm", value: bolum?.ad, icon: "📚" },
            { label: "Hesap Tipi", value: profile?.role === "admin" ? "Admin" : "Öğrenci", icon: "🔑" },
          ].map((item, i) => (
            <div key={i} style={{
              padding: "16px 22px",
              borderRight: `1px solid ${tokens.border}`,
              borderBottom: `1px solid ${tokens.border}`,
            }}>
              <div style={{ fontSize: 11, color: tokens.muted, fontWeight: 600, textTransform: "uppercase", letterSpacing: 0.5, marginBottom: 6 }}>
                {item.icon} {item.label}
              </div>
              <div style={{ fontSize: 14, fontWeight: 700, color: item.value ? tokens.textPrimary : tokens.muted }}>
                {item.value || "—"}
              </div>
            </div>
          ))}
        </div>
      </div>

      {usernameModal && (
        <Overlay onClick={() => setUsernameModal(false)}>
          <div style={{ background: tokens.card, border: `1px solid ${tokens.border}`, borderRadius: 20, padding: 28, maxWidth: 400, width: "90%", textAlign: "center", boxShadow: tokens.shadowLg }} onClick={(e) => e.stopPropagation()}>
            <div style={{ fontSize: 36, marginBottom: 16 }}>👤</div>
            <h3 style={{ color: tokens.textPrimary, margin: "0 0 8px", fontSize: 19 }}>Kullanıcı Adı Belirle</h3>
            <p style={{ color: tokens.muted, fontSize: 13, margin: "0 0 24px" }}>Sadece harf, rakam, alt çizgi ve nokta kullanabilirsiniz.</p>
            <input 
              value={usernameInput} 
              onChange={(e) => setUsernameInput(e.target.value)} 
              placeholder="kullanici_adi" 
              style={{ ...inputStyle, textAlign: "center", marginBottom: 24, fontSize: 15, fontWeight: 600, letterSpacing: 0.5 }} 
              onFocus={(e) => setTimeout(() => e.target.select(), 10)}
            />
            <div style={{ display: "flex", gap: 10, justifyContent: "center" }}>
              <button onClick={() => setUsernameModal(false)} style={{ padding: "10px 20px", borderRadius: 10, border: `1px solid ${tokens.border}`, background: "transparent", color: tokens.textSecondary, cursor: "pointer", fontWeight: 600, fontSize: 13, transition: "background 0.2s" }} onMouseEnter={(e) => e.target.style.background = tokens.surface} onMouseLeave={(e) => e.target.style.background = "transparent"}>İptal</button>
              <button onClick={saveUsername} style={{ padding: "10px 20px", borderRadius: 10, border: "none", background: tokens.primary, color: "#fff", cursor: "pointer", fontWeight: 600, fontSize: 13, transition: "opacity 0.2s", boxShadow: `0 4px 14px ${tokens.primary}40` }} onMouseEnter={(e) => e.target.style.opacity = 0.85} onMouseLeave={(e) => e.target.style.opacity = 1}>Kaydet</button>
            </div>
          </div>
        </Overlay>
      )}
    </div>
  );
}

function SettingCard({ tokens, icon, title, children }) {
  return (
    <div style={{
      background: tokens.card, border: `1px solid ${tokens.border}`,
      borderRadius: 16, overflow: "hidden",
    }}>
      <div style={{ padding: "14px 18px", borderBottom: `1px solid ${tokens.border}`, display: "flex", alignItems: "center", gap: 8 }}>
        <div style={{ width: 28, height: 28, borderRadius: 8, background: tokens.primary + "18", display: "flex", alignItems: "center", justifyContent: "center", color: tokens.primary }}>
          {icon}
        </div>
        <span style={{ fontSize: 13, fontWeight: 700, color: tokens.textPrimary }}>{title}</span>
      </div>
      <div style={{ padding: "14px 18px" }}>{children}</div>
    </div>
  );
}

function ToggleRow({ tokens, label, sub, checked, onChange }) {
  return (
    <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", padding: "10px 0", borderBottom: `1px solid ${tokens.border}` }}>
      <div>
        <div style={{ fontSize: 12.5, fontWeight: 600, color: tokens.textPrimary }}>{label}</div>
        <div style={{ fontSize: 11, color: tokens.muted, marginTop: 1 }}>{sub}</div>
      </div>
      <button onClick={() => onChange(!checked)} style={{
        width: 40, height: 22, borderRadius: 99, border: "none", flexShrink: 0,
        background: checked ? tokens.primary : tokens.border + "80",
        cursor: "pointer", position: "relative", transition: "background 200ms ease",
      }}>
        <span style={{
          position: "absolute", top: 3, left: checked ? 20 : 3,
          width: 16, height: 16, borderRadius: 99, background: "#fff",
          transition: "left 200ms ease", boxShadow: "0 1px 4px rgba(0,0,0,0.3)",
        }} />
      </button>
    </div>
  );
}

function ExportButton({ onClick, tokens, color, icon, children }) {
  return (
    <button onClick={onClick} style={{
      display: "flex", alignItems: "center", gap: 8,
      padding: "9px 14px", borderRadius: 10, border: `1px solid ${color}30`,
      background: color + "10", color: tokens.textPrimary,
      fontWeight: 600, fontSize: 12.5, cursor: "pointer",
      fontFamily: "inherit", transition: "all 0.2s", width: "100%",
    }}
      onMouseEnter={e => { e.currentTarget.style.background = color + "20"; e.currentTarget.style.borderColor = color + "50"; }}
      onMouseLeave={e => { e.currentTarget.style.background = color + "10"; e.currentTarget.style.borderColor = color + "30"; }}
    >
      <span style={{ fontSize: 14, color }}>{icon}</span>
      {children}
    </button>
  );
}
