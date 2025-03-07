CREATE TABLE public.secret_data (
    id SERIAL PRIMARY KEY,
    username VARCHAR(30) NOT NULL,
    secret_token BYTEA NOT NULL
);

-- Установка расширения pgcrypto
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Вставка зашифрованных данных
INSERT INTO public.secret_data (username, secret_token)
VALUES (
    'operator_1', pgp_sym_encrypt('token_', '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08')
);

-- Проверка зашифрованных данных
-- SELECT * FROM public.secret_data;

-- Попытка расшифровки данных без ключа
-- SELECT pgp_sym_decrypt(secret_token::bytea, 'wrong_key') FROM public.secret_data;

-- SELECT username, 
--        pgp_sym_decrypt(secret_token, '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08') AS decrypted_token
-- FROM public.secret_data;
