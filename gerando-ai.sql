### Criar tebela de transações
### Criar tebela de transações_diaria
### Criar tebela de transações_mensais

-- Tabela de Transações
DROP TABLE IF EXISTS transacoes CASCADE;
CREATE TABLE transacoes (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    data_insercao TIMESTAMPTZ DEFAULT NOW(),
    id_usuario UUID NOT NULL,
    valor NUMERIC(10, 2) NOT NULL,
    categoria TEXT CHECK (categoria IN ('entrada', 'saida')) NOT NULL,
    destinatario TEXT NOT NULL
);

-- Tabela de Resumo de Transações
DROP TABLE IF EXISTS resumo_transacoes CASCADE;
CREATE TABLE resumo_transacoes (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    data DATE NOT NULL,
    categoria TEXT CHECK (categoria IN ('entrada', 'saida')) NOT NULL,
    total_valor NUMERIC(10, 2) NOT NULL
);

-- Função e Trigger para Resumo de Transações
CREATE OR REPLACE FUNCTION atualizar_resumo_transacoes() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO resumo_transacoes (data, categoria, total_valor)
    VALUES (NEW.data_insercao::DATE, NEW.categoria, NEW.valor)
    ON CONFLICT (data, categoria) DO UPDATE
    SET total_valor = resumo_transacoes.total_valor + EXCLUDED.total_valor;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_atualizar_resumo
AFTER INSERT ON transacoes
FOR EACH ROW EXECUTE FUNCTION atualizar_resumo_transacoes();

-- Tabela de Resumo de Transações Mensal
DROP TABLE IF EXISTS resumo_transacoes_mensal CASCADE;
CREATE TABLE resumo_transacoes_mensal (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    ano INT NOT NULL,
    mes INT NOT NULL,
    categoria TEXT CHECK (categoria IN ('entrada', 'saida')) NOT NULL,
    total_valor NUMERIC(10, 2) NOT NULL,
    UNIQUE (ano, mes, categoria)
);

-- Função e Trigger para Resumo de Transações Mensal
CREATE OR REPLACE FUNCTION atualizar_resumo_transacoes_mensal() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO resumo_transacoes_mensal (ano, mes, categoria, total_valor)
    VALUES (EXTRACT(YEAR FROM NEW.data), EXTRACT(MONTH FROM NEW.data), NEW.categoria, NEW.total_valor)
    ON CONFLICT (ano, mes, categoria) DO UPDATE
    SET total_valor = resumo_transacoes_mensal.total_valor + EXCLUDED.total_valor;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_atualizar_resumo_mensal
AFTER INSERT OR UPDATE ON resumo_transacoes
FOR EACH ROW EXECUTE FUNCTION atualizar_resumo_transacoes_mensal();


# there is no unique or exclusion contraint mathing the ON CONFLICT specification

# solução

ALTER TABLE resumo_transacoes
ADD CONSTRAINT unique_data_categoria UNIQUE (data, categoria);

## SOLUÇÃO
CREATE OR REPLACE FUNCTION atualizar_resumo_transacoes_mensal() RETURNS TRIGGER AS $$
DECLARE
    total_mensal NUMERIC(10, 2);
BEGIN
    -- Calcula o total mensal para a categoria
    SELECT SUM(total_valor) INTO total_mensal
    FROM resumo_transacoes
    WHERE EXTRACT(YEAR FROM data) = EXTRACT(YEAR FROM NEW.data)
      AND EXTRACT(MONTH FROM data) = EXTRACT(MONTH FROM NEW.data)
      AND categoria = NEW.categoria;

    -- Insere ou atualiza o total mensal
    INSERT INTO resumo_transacoes_mensal (ano, mes, categoria, total_valor)
    VALUES (EXTRACT(YEAR FROM NEW.data), EXTRACT(MONTH FROM NEW.data), NEW.categoria, total_mensal)
    ON CONFLICT (ano, mes, categoria) DO UPDATE
    SET total_valor = EXCLUDED.total_valor;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


## GATILHO
CREATE OR replace TRIGGER trigger_atualizar_resumo_mensal
AFTER INSERT OR UPDATE ON resumo_transacoes
FOR EACH ROW EXECUTE FUNCTION atualizar_resumo_transacoes_mensal();
