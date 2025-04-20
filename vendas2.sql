# drop table vendas2

# modelo de criação 1
create table vendas (
  id uuid primary key default gen_random_uuid(),
  nome text not null,
  quantidade integer not null,
  preco_custo numeric not null,
  percentual numeric not null,
  preco_venda numeric, -- será calculado automaticamente
  created_at timestamp with time zone default now()
);

# modelo de criação 2
create table vendas2 (
  id serial primary key,
  nome text not null,
  quantidade integer not null,
  preco_custo numeric not null,
  percentual numeric not null,
  preco_venda numeric, -- será calculado automaticamente
  created_at timestamp with time zone default now()
);

insert into vendas2 (nome, quantidade, preco_custo, percentual) values
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