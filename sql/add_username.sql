ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS username text UNIQUE;

CREATE OR REPLACE FUNCTION get_email_by_full_name(p_name text)
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_email text;
BEGIN
  -- İsme VEYA kullanıcı adına göre tam eşleşen kullanıcının e-postasını bulur
  SELECT email INTO v_email FROM public.profiles 
  WHERE full_name = p_name OR username = p_name 
  LIMIT 1;
  RETURN v_email;
END;
$$;
