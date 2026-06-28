import { useState, useEffect, useCallback } from "react";

const STORAGE_KEY = "unipulse-hedef-gano";

const DEFAULT_HEDEF = 3.00;

function parse(v) {
  const n = parseFloat(v);
  if (isNaN(n) || n < 0 || n > 4) return null;
  return n;
}

/**
 * Kullanıcının Hedef GPA'sını localStorage'da saklar.
 * Supabase profil şemasını değiştirmeden kişiselleştirilebilir hedef.
 */
export function useHedefGano() {
  const [hedefGano, setHedefGanoState] = useState(() => {
    if (typeof window === "undefined") return DEFAULT_HEDEF;
    try {
      const stored = window.localStorage.getItem(STORAGE_KEY);
      const parsed = parse(stored);
      return parsed !== null ? parsed : DEFAULT_HEDEF;
    } catch {
      return DEFAULT_HEDEF;
    }
  });

  const setHedefGano = useCallback((value) => {
    const parsed = parse(value);
    if (parsed === null) return false;
    setHedefGanoState(parsed);
    try {
      window.localStorage.setItem(STORAGE_KEY, String(parsed));
    } catch {}
    return true;
  }, []);

  const resetHedefGano = useCallback(() => {
    setHedefGanoState(DEFAULT_HEDEF);
    try {
      window.localStorage.removeItem(STORAGE_KEY);
    } catch {}
  }, []);

  useEffect(() => {
    // Cross-tab sync
    const handler = (e) => {
      if (e.key !== STORAGE_KEY) return;
      const parsed = parse(e.newValue);
      if (parsed !== null) setHedefGanoState(parsed);
    };
    window.addEventListener("storage", handler);
    return () => window.removeEventListener("storage", handler);
  }, []);

  return { hedefGano, setHedefGano, resetHedefGano, defaultHedef: DEFAULT_HEDEF };
}
