
# 1. Criar a tabela Você pode executar este SQL no Supabase SQL Editor:

create table vendas (
  id int primary key default gen_random_uuid(),
  nome text not null,
  quantidade integer not null,
  preco_custo numeric not null,
  percentual numeric not null,
  preco_venda numeric, -- será calculado automaticamente
  created_at timestamp with time zone default now()
);


# 2. Criar a função que calcula o preco_venda
create or replace function calcular_preco_venda()
returns trigger as $$
begin
  new.preco_venda := new.preco_custo * new.percentual;
  return new;
end;
$$ language plpgsql;

# 3. Criar o trigger que usa essa função ao inserir ou atualizar
create trigger trigger_calcula_preco_venda
before insert or update on vendas
for each row
execute function calcular_preco_venda();


# Agora, sempre que você fizer um INSERT ou UPDATE na tabela vendas, 
# o Supabase (PostgreSQL) vai calcular automaticamente o preco_venda 
# com base no preco_custo * percentual.
# Se quiser um exemplo de como inserir dados:

insert into vendas (nome, quantidade, preco_custo, percentual)
values ('Produto A', 10, 20.00, 1.5);

# Inserindo registros

insert into vendas (nome, quantidade, preco_custo, percentual) values
('Camiseta Básica', 50, 20.00, 1.5),
('Calça Jeans', 30, 40.00, 1.6),
('Tênis Esportivo', 20, 100.00, 1.4),
('Jaqueta de Couro', 10, 150.00, 1.8),
('Relógio Digital', 15, 80.00, 1.7),
('Boné Estiloso', 40, 15.00, 2.0),
('Mochila Escolar', 25, 60.00, 1.5),
('Meia de Algodão', 100, 5.00, 2.2),
('Óculos de Sol', 18, 70.00, 1.6),
('Carteira de Couro', 35, 25.00, 1.9);

