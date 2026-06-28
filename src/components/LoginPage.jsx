import { useState } from "react";
import { useAuth } from "../context/AuthContext";

const inputStyle = {
  width: "100%", height: 44, padding: "0 14px", borderRadius: 10,
  background: "rgba(255,255,255,0.04)", border: "1px solid rgba(255,255,255,0.08)",
  color: "#F1F5F9", fontSize: 14, outline: "none", boxSizing: "border-box",
  transition: "all 0.2s ease", fontFamily: "inherit",
};

const labelStyle = {
  display: "block", fontSize: 12, color: "rgba(241,245,249,0.6)",
  fontWeight: 600, marginBottom: 6, letterSpacing: "0.2px",
};

const focusHandlers = {
  onFocus: (e) => { e.target.style.borderColor = "rgba(99,102,241,0.5)"; e.target.style.background = "rgba(99,102,241,0.06)"; e.target.style.boxShadow = "0 0 0 3px rgba(99,102,241,0.12)"; },
  onBlur: (e) => { e.target.style.borderColor = "rgba(255,255,255,0.08)"; e.target.style.background = "rgba(255,255,255,0.04)"; e.target.style.boxShadow = "none"; },
};

const INDIGO = "#6366F1";
const INDIGO_LIGHT = "#818CF8";

function Logo({ size = 32 }) {
  return (
    <svg width={size} height={size} viewBox="0 0 64 64" fill="none">
      <defs>
        <linearGradient id="logoGrad" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stopColor={INDIGO_LIGHT}/>
          <stop offset="100%" stopColor={INDIGO}/>
        </linearGradient>
      </defs>
      <polyline points="6,34 16,34 22,20 28,48 34,26 38,38 44,30 50,34 58,34"
        fill="none" stroke="url(#logoGrad)" strokeWidth="4.5"
        strokeLinecap="round" strokeLinejoin="round"/>
    </svg>
  );
}

export default function LoginPage({ onSwitch }) {
  const { login, loginWithGoogle, resetPassword } = useAuth();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const [remember, setRemember] = useState(false);
  const [forgotOpen, setForgotOpen] = useState(false);
  const [forgotEmail, setForgotEmail] = useState("");
  const [forgotLoading, setForgotLoading] = useState(false);
  const [forgotSent, setForgotSent] = useState(false);
  const [forgotError, setForgotError] = useState("");

  async function handleSubmit(e) {
    e.preventDefault();
    setError("");
    setLoading(true);
    try {
      await login(email, password);
    } catch (err) {
      setError(err.message === "Invalid login credentials" ? "E-posta veya şifre hatalı" : err.message);
    } finally {
      setLoading(false);
    }
  }

  async function handleForgotPassword(e) {
    e.preventDefault();
    setForgotError("");
    setForgotLoading(true);
    try {
      await resetPassword(forgotEmail);
      setForgotSent(true);
    } catch (err) {
      setForgotError(err.message);
    } finally {
      setForgotLoading(false);
    }
  }

  function closeForgot() {
    setForgotOpen(false);
    setForgotSent(false);
    setForgotEmail("");
    setForgotError("");
  }

  return (
    <div style={{
      minHeight: "100vh", background: "#070B14",
      fontFamily: "'Inter', -apple-system, BlinkMacSystemFont, sans-serif",
      display: "flex", alignItems: "center", justifyContent: "center",
      position: "relative", overflow: "hidden",
    }}>
      {/* Background: subtle grid + indigo glow */}
      <div className="bg-grid" style={{ position: "fixed", inset: 0, opacity: 0.6, pointerEvents: "none", zIndex: 0 }} />
      <div style={{ position: "fixed", top: 0, left: 0, width: "100%", height: "100%", pointerEvents: "none", zIndex: 0 }}>
        <div style={{ position: "absolute", top: "-200px", left: "-200px", width: 720, height: 720, borderRadius: "50%", background: INDIGO, filter: "blur(150px)", opacity: 0.32 }} />
        <div style={{ position: "absolute", bottom: "-180px", right: "-180px", width: 560, height: 560, borderRadius: "50%", background: "#0EA5E9", filter: "blur(150px)", opacity: 0.22 }} />
      </div>

      {/* Watermark */}
      <div style={{
        position: "fixed", top: "50%", left: "50%", transform: "translate(-50%, -50%)",
        fontSize: 180, fontWeight: 800, letterSpacing: 28,
        color: "white", opacity: 0.025, whiteSpace: "nowrap",
        userSelect: "none", pointerEvents: "none", zIndex: 0,
      }}>UNIPULSE</div>

      {/* Card */}
      <div style={{
        width: 400, background: "rgba(15, 22, 35, 0.7)",
        backdropFilter: "blur(24px) saturate(180%)", WebkitBackdropFilter: "blur(24px) saturate(180%)",
        borderRadius: 20, border: "1px solid rgba(255,255,255,0.08)",
        padding: "32px 32px 28px", position: "relative", zIndex: 1,
        boxShadow: "0 25px 50px -12px rgba(0,0,0,0.5), 0 0 0 1px rgba(255,255,255,0.04) inset, 0 0 80px rgba(99,102,241,0.08)",
      }}>
        {/* Brand */}
        <div style={{ textAlign: "center", marginBottom: 28 }}>
          <div style={{
            display: "inline-flex", justifyContent: "center", alignItems: "center",
            width: 52, height: 52, background: "rgba(99,102,241,0.08)",
            borderRadius: 14, marginBottom: 14, border: "1px solid rgba(99,102,241,0.2)",
            boxShadow: "0 8px 24px rgba(99,102,241,0.18)",
          }}>
            <Logo size={30} />
          </div>
          <h1 style={{
            margin: "0 0 4px", fontSize: 22, fontWeight: 700, letterSpacing: "-0.5px",
            color: "#F1F5F9",
          }}>UniPulse</h1>
          <p style={{ margin: 0, fontSize: 12, color: "rgba(241,245,249,0.5)" }}>
            Üniversite hayatının kontrol merkezi
          </p>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit}>
          <div style={{ marginBottom: 14 }}>
            <label style={labelStyle}>E-posta veya Kullanıcı Adı</label>
            <input type="text" value={email} onChange={(e) => setEmail(e.target.value)} placeholder="ornek@edu.tr veya kullaniciadi" required style={inputStyle} {...focusHandlers} />
          </div>

          <div style={{ marginBottom: 16 }}>
            <label style={labelStyle}>Şifre</label>
            <input type="password" autoComplete="current-password" value={password} onChange={(e) => setPassword(e.target.value)} placeholder="••••••••" required minLength={6} style={inputStyle} {...focusHandlers} />
          </div>

          {/* Options */}
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 18 }}>
            <label style={{ display: "flex", alignItems: "center", gap: 8, fontSize: 12, color: "rgba(241,245,249,0.55)", cursor: "pointer", userSelect: "none" }}>
              <input type="checkbox" checked={remember} onChange={(e) => setRemember(e.target.checked)} style={{ display: "none" }} />
              <span style={{
                width: 16, height: 16, border: "1.5px solid rgba(255,255,255,0.12)",
                borderRadius: 5, display: "flex", justifyContent: "center", alignItems: "center",
                transition: "all 0.2s ease", background: "rgba(255,255,255,0.04)", flexShrink: 0,
                ...(remember ? { background: `linear-gradient(135deg, ${INDIGO}, ${INDIGO_LIGHT})`, borderColor: "transparent" } : {}),
              }}>
                {remember && <svg width="9" height="9" viewBox="0 0 10 10" fill="none"><path d="M2 5L4 7L8 3" stroke="white" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/></svg>}
              </span>
              <span>Beni hatırla</span>
            </label>
            <button type="button" onClick={() => setForgotOpen(true)} style={{ background: "none", border: "none", fontSize: 12, color: INDIGO_LIGHT, cursor: "pointer", fontFamily: "inherit", padding: 0, fontWeight: 600, transition: "color 0.15s" }}
              onMouseEnter={(e) => e.target.style.color = "#A5B4FC"}
              onMouseLeave={(e) => e.target.style.color = INDIGO_LIGHT}
            >Şifremi unuttum?</button>
          </div>

          {error && (
            <div style={{ background: "rgba(239,68,68,0.08)", border: "1px solid rgba(239,68,68,0.2)", borderRadius: 10, padding: "10px 14px", marginBottom: 14, color: "#FCA5A5", fontSize: 12.5, display: "flex", alignItems: "center", gap: 8 }}>
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
              {error}
            </div>
          )}

          <button type="submit" disabled={loading} style={{
            width: "100%", height: 46, borderRadius: 10, border: "none",
            background: loading ? "rgba(99,102,241,0.3)" : `linear-gradient(135deg, ${INDIGO} 0%, ${INDIGO_LIGHT} 100%)`,
            color: "#fff", cursor: loading ? "default" : "pointer",
            fontWeight: 600, fontSize: 14, fontFamily: "inherit",
            transition: "all 0.25s ease",
            boxShadow: loading ? "none" : "0 8px 20px rgba(99,102,241,0.35), 0 0 0 1px rgba(99,102,241,0.2) inset",
          }}
            onMouseEnter={(e) => { if (!loading) { e.currentTarget.style.transform = "translateY(-1px)"; e.currentTarget.style.boxShadow = "0 12px 28px rgba(99,102,241,0.45), 0 0 0 1px rgba(99,102,241,0.3) inset"; }}}
            onMouseLeave={(e) => { if (!loading) { e.currentTarget.style.transform = "translateY(0)"; e.currentTarget.style.boxShadow = "0 8px 20px rgba(99,102,241,0.35), 0 0 0 1px rgba(99,102,241,0.2) inset"; }}}
          >{loading ? "Giriş yapılıyor..." : "Giriş Yap"}</button>
        </form>

        {/* Divider */}
        <div style={{ display: "flex", alignItems: "center", margin: "20px 0" }}>
          <div style={{ flex: 1, height: 1, background: "rgba(255,255,255,0.06)" }} />
          <span style={{ padding: "0 14px", fontSize: 11, color: "rgba(241,245,249,0.4)", fontWeight: 500 }}>veya</span>
          <div style={{ flex: 1, height: 1, background: "rgba(255,255,255,0.06)" }} />
        </div>

        {/* Google Button */}
        <button onClick={loginWithGoogle} style={{
          width: "100%", height: 44, borderRadius: 10,
          background: "rgba(255,255,255,0.04)", border: "1px solid rgba(255,255,255,0.08)",
          color: "#F1F5F9", cursor: "pointer", fontSize: 13.5, fontWeight: 600,
          fontFamily: "inherit", transition: "all 0.2s ease",
          display: "flex", justifyContent: "center", alignItems: "center", gap: 10,
        }}
          onMouseEnter={(e) => { e.currentTarget.style.background = "rgba(255,255,255,0.07)"; e.currentTarget.style.borderColor = "rgba(255,255,255,0.14)"; }}
          onMouseLeave={(e) => { e.currentTarget.style.background = "rgba(255,255,255,0.04)"; e.currentTarget.style.borderColor = "rgba(255,255,255,0.08)"; }}
        >
          <svg width="16" height="16" viewBox="0 0 18 18">
            <path d="M17.64 9.2c0-.637-.057-1.251-.164-1.84H9v3.481h4.844c-.209 1.125-.843 2.078-1.796 2.717v2.258h2.908c1.702-1.567 2.684-3.875 2.684-6.615z" fill="#4285F4"/>
            <path d="M9 18c2.43 0 4.467-.806 5.956-2.18l-2.908-2.259c-.806.54-1.837.86-3.048.86-2.344 0-4.328-1.584-5.036-3.711H.957v2.332C2.438 15.983 5.482 18 9 18z" fill="#34A853"/>
            <path d="M3.964 10.71c-.18-.54-.282-1.117-.282-1.71s.102-1.17.282-1.71V4.958H.957C.347 6.173 0 7.548 0 9s.348 2.827.957 4.042l3.007-2.332z" fill="#FBBC05"/>
            <path d="M9 3.58c1.321 0 2.508.454 3.44 1.345l2.582-2.58C13.463.891 11.426 0 9 0 5.482 0 2.438 2.017.957 4.958L3.964 7.29C4.672 5.163 6.656 3.58 9 3.58z" fill="#EA4335"/>
          </svg>
          Google ile Devam Et
        </button>

        {/* Footer */}
        <div style={{ textAlign: "center", marginTop: 22, fontSize: 13, color: "rgba(241,245,249,0.5)" }}>
          Hesabın yok mu?{" "}
          <button type="button" onClick={onSwitch} style={{ background: "none", border: "none", color: INDIGO_LIGHT, cursor: "pointer", fontWeight: 600, fontSize: 13, padding: 0, fontFamily: "inherit", transition: "color 0.15s" }}
            onMouseEnter={(e) => e.target.style.color = "#A5B4FC"}
            onMouseLeave={(e) => e.target.style.color = INDIGO_LIGHT}
          >Kayıt Ol</button>
        </div>
      </div>

      {/* Forgot Password Modal */}
      {forgotOpen && (
        <div onClick={closeForgot} style={{
          position: "fixed", inset: 0, background: "rgba(7, 11, 20, 0.7)",
          backdropFilter: "blur(8px)", WebkitBackdropFilter: "blur(8px)",
          display: "flex", alignItems: "center", justifyContent: "center", zIndex: 100,
        }}>
          <div onClick={(e) => e.stopPropagation()} style={{
            width: 380, background: "rgba(15, 22, 35, 0.92)",
            backdropFilter: "blur(24px) saturate(180%)", WebkitBackdropFilter: "blur(24px) saturate(180%)",
            borderRadius: 20, border: "1px solid rgba(255,255,255,0.08)",
            padding: "30px 32px", position: "relative", zIndex: 1,
            boxShadow: "0 25px 50px -12px rgba(0,0,0,0.6), 0 0 60px rgba(99,102,241,0.06)",
          }}>
            <button onClick={closeForgot} style={{
              position: "absolute", top: 14, right: 14,
              background: "rgba(255,255,255,0.05)", border: "1px solid rgba(255,255,255,0.08)",
              color: "rgba(241,245,249,0.5)", borderRadius: 8, width: 30, height: 30,
              cursor: "pointer", fontSize: 14, display: "flex", alignItems: "center", justifyContent: "center",
              fontFamily: "inherit", transition: "all 0.2s",
            }}
              onMouseEnter={(e) => { e.currentTarget.style.color = "#F1F5F9"; e.currentTarget.style.background = "rgba(255,255,255,0.1)"; }}
              onMouseLeave={(e) => { e.currentTarget.style.color = "rgba(241,245,249,0.5)"; e.currentTarget.style.background = "rgba(255,255,255,0.05)"; }}
            >✕</button>

            {!forgotSent ? (
              <>
                <div style={{ textAlign: "center", marginBottom: 22 }}>
                  <div style={{
                    width: 48, height: 48, borderRadius: 14,
                    background: "rgba(99,102,241,0.1)", border: "1px solid rgba(99,102,241,0.22)",
                    display: "flex", alignItems: "center", justifyContent: "center",
                    margin: "0 auto 16px",
                  }}>
                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke={INDIGO_LIGHT} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                  </div>
                  <h2 style={{ margin: "0 0 6px", fontSize: 18, fontWeight: 700, color: "#F1F5F9", letterSpacing: -0.3 }}>Şifre Sıfırlama</h2>
                  <p style={{ margin: 0, fontSize: 12.5, color: "rgba(241,245,249,0.5)", lineHeight: 1.55 }}>
                    E-posta adresinizi girin, size şifre sıfırlama bağlantısı göndereceğiz.
                  </p>
                </div>

                <form onSubmit={handleForgotPassword}>
                  <div style={{ marginBottom: 16 }}>
                    <label style={labelStyle}>E-posta</label>
                    <input type="email" value={forgotEmail} onChange={(e) => setForgotEmail(e.target.value)} placeholder="ornek@university.edu.tr" required style={inputStyle} {...focusHandlers} />
                  </div>

                  {forgotError && (
                    <div style={{ background: "rgba(239,68,68,0.08)", border: "1px solid rgba(239,68,68,0.2)", borderRadius: 8, padding: "8px 12px", marginBottom: 12, color: "#FCA5A5", fontSize: 11.5 }}>{forgotError}</div>
                  )}

                  <button type="submit" disabled={forgotLoading} style={{
                    width: "100%", height: 44, borderRadius: 10, border: "none",
                    background: forgotLoading ? "rgba(99,102,241,0.3)" : `linear-gradient(135deg, ${INDIGO} 0%, ${INDIGO_LIGHT} 100%)`,
                    color: "#fff", cursor: forgotLoading ? "default" : "pointer",
                    fontWeight: 600, fontSize: 13.5, fontFamily: "inherit",
                    boxShadow: forgotLoading ? "none" : "0 8px 20px rgba(99,102,241,0.32)",
                  }}>{forgotLoading ? "Gönderiliyor..." : "Sıfırlama Bağlantısı Gönder"}</button>
                </form>
              </>
            ) : (
              <div style={{ textAlign: "center" }}>
                <div style={{
                  width: 56, height: 56, borderRadius: 16,
                  background: "rgba(16,185,129,0.1)", border: "1px solid rgba(16,185,129,0.25)",
                  display: "flex", alignItems: "center", justifyContent: "center",
                  margin: "0 auto 18px",
                }}>
                  <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="#34D399" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                </div>
                <h2 style={{ margin: "0 0 8px", fontSize: 18, fontWeight: 700, color: "#F1F5F9", letterSpacing: -0.3 }}>Bağlantı Gönderildi!</h2>
                <p style={{ margin: "0 0 6px", fontSize: 13, color: "rgba(241,245,249,0.6)", lineHeight: 1.55 }}>
                  <strong style={{ color: "#F1F5F9" }}>{forgotEmail}</strong> adresine şifre sıfırlama bağlantısı gönderdik.
                </p>
                <p style={{ margin: "0 0 22px", fontSize: 12, color: "rgba(241,245,249,0.4)", lineHeight: 1.55 }}>
                  E-posta kutunuzu kontrol edin.
                </p>
                <button onClick={closeForgot} style={{
                  width: "100%", height: 44, borderRadius: 10, border: "none",
                  background: `linear-gradient(135deg, ${INDIGO} 0%, ${INDIGO_LIGHT} 100%)`,
                  color: "#fff", cursor: "pointer", fontWeight: 600, fontSize: 13.5,
                  fontFamily: "inherit", boxShadow: "0 8px 20px rgba(99,102,241,0.32)",
                }}>Giriş Sayfasına Dön</button>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
