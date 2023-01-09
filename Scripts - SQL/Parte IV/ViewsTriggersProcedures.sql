/* Grupo 5 - Banco de Dados I
 
Alunos:
 
- Davyson Douglas Gomes Guimarães - 119210872.
- Henrique Dias Oliveira de Nóbrega - 120210069.
- José Artur Procopio Coelho - 120210625.
- Lucas Riberio Agra Alexandre - 119210120.
- Paulo Victor Machado de Souza - 120110398.
- Victor Alexandre Cavalcanti Macedo - 120210046.
 
*/

-- Questão #1:

FUNCTION calcula_total_cliente (p_codigo_cliente NUMBER)
RETURN NUMBER
IS
   v_total NUMBER;
BEGIN
   SELECT SUM(valor) INTO v_total
   FROM notas_fiscais
   WHERE codigo_cliente = p_codigo_cliente;

   RETURN v_total;
END;

-- Questão #2:

PROCEDURE devolver_estoque (p_codigo_ordem NUMBER)
IS
BEGIN
   UPDATE estoques
   SET quantidade = quantidade + i.quantidade
   FROM itens_ordem_compra i
   WHERE i.codigo_ordem = p_codigo_ordem AND estoques.codigo_produto = i.codigo_produto;
END;

-- Questão #3:

PROCEDURE remover_avaliacao_falsa (p_codigo_produto NUMBER)
IS
BEGIN
   DELETE FROM avaliacoes
   WHERE codigo_ordem IN (SELECT o.codigo
                        FROM ordens_compra o
                        JOIN itens_ordem_compra i ON o.codigo = i.codigo_ordem
                        WHERE i.codigo_produto = p_codigo_produto AND o.status <> 'FINALIZADA');
END;

-- Questão #4:

CREATE VIEW vw_compras_finalizadas AS
SELECT c.codigo, c.nome, SUM(oc.quantidade * p.preco) AS valor_total
FROM clientes c
JOIN ordens_compra oc ON c.codigo = oc.codigo_cliente
JOIN itens_ordem_compra ioc ON oc.codigo = ioc.codigo_ordem
JOIN produtos p ON ioc.codigo_produto = p.codigo
WHERE oc.status = 'FINALIZADA'
GROUP BY c.codigo, c.nome

SELECT * FROM vw_compras_finalizadas;

-- Questão #5:

CREATE VIEW vw_clientes_indicados_antes_2018 AS
SELECT c1.codigo, c1.nome, i.data, c2.codigo, c2.nome
FROM clientes c1
JOIN indicacoes i ON c1.codigo = i.codigo_cliente
JOIN clientes c2 ON i.codigo_cliente_indicador = c2.codigo
WHERE i.data < '2018-01-01'

-- Para selecionar os dados dessa view:

SELECT * FROM vw_clientes_indicados_antes_2018;

-- Questão #6:

CREATE VIEW vw_clientes_sp_iphone11 AS
SELECT c.nome
FROM clientes c
JOIN ordens_compra oc ON c.codigo = oc.codigo_cliente
JOIN itens_ordem_compra ioc ON oc.codigo = ioc.codigo_ordem
JOIN produtos p ON ioc.codigo_produto = p.codigo
WHERE c.cidade = 'São Paulo' AND p.nome = 'Iphone 11'

-- Para selecionar os dados dessa view:

SELECT * FROM vw_clientes_sp_iphone11;

-- Questão #7:

CREATE TRIGGER trg_baixa_estoque
AFTER INSERT ON itens_ordem_compra
FOR EACH ROW
BEGIN
   UPDATE produtos SET estoque = estoque - :NEW.quantidade WHERE codigo = :NEW.codigo_produto;
END;

-- Questão #8:

CREATE TRIGGER trg_nome_fornecedor
BEFORE INSERT OR UPDATE ON fornecedores
FOR EACH ROW
BEGIN
   :NEW.nome := UPPER(SUBSTR(:NEW.nome, 1, 1)) || SUBSTR(:NEW.nome, 2);
END;

-- Questão #9:

CREATE TRIGGER trg_end_num
BEFORE INSERT ON clientes
FOR EACH ROW
BEGIN
   IF :NEW.endereco = 'END_NUM' THEN
      :NEW.endereco := 's/n';
   END IF;
END;