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

CREATE OR REPLACE FUNCTION calcula_total_cliente (p_codigo_cliente IN NUMBER)
RETURN NUMBER
IS
  v_total NUMBER := 0;
BEGIN
  SELECT SUM(nf.valor_total)
  INTO v_total
  FROM nota_fiscal nf
    JOIN ordem_de_compra oc ON nf.cod_ordem_compra = oc.codordem
  WHERE oc.codigo_cliente = p_codigo_cliente;

  RETURN v_total;
END;

-- Questão #2:

CREATE OR REPLACE PROCEDURE devolver_estoque (p_codigo_ordem IN NUMBER) IS
BEGIN
  UPDATE produto p
  SET quantidade = quantidade + (
    SELECT quantidade
    FROM compra_produto cp
    WHERE cp.codigo_produto = p.codprod AND cp.codigo_compra = p_codigo_ordem
  )
  WHERE EXISTS (
    SELECT 1
    FROM compra_produto cp
    WHERE cp.codigo_produto = p.codprod AND cp.codigo_compra = p_codigo_ordem
  );
END;

-- Questão #3:

CREATE OR REPLACE PROCEDURE remover_avaliacao_falsa (p_codigo_produto IN NUMBER) IS
BEGIN
  DELETE FROM compra_avalia_produto
  WHERE CODIGO_COMPRA IN (
    SELECT CODORDEM
    FROM ordem_de_compra
    WHERE codigo_produto = p_codigo_produto AND status != 'FINALIZADA'
  );
END;

-- Questão #4:

CREATE OR REPLACE VIEW vw_compras_finalizadas AS
SELECT c.codcli, c.nome, SUM(cp.quantidade * p.preco_venda) AS valor_total
FROM cliente c
JOIN ordem_de_compra oc ON c.codcli = oc.codigo_cliente
JOIN compra_produto cp on oc.codordem = cp.codigo_compra
JOIN produto p ON cp.codigo_produto = p.codprod
WHERE oc.status = 'FINALIZADA'
GROUP BY c.codcli, c.nome;

-- Para selecionar os dados dessa view:

SELECT * FROM vw_compras_finalizadas;

-- Questão #5:

CREATE VIEW vw_clientes_indicados_antes_2018 AS
SELECT c2.codcli, c2.nome, c2.data_indicacao, c1.codcli as codcli_indicou, c1.nome as nomecli_indicou
FROM cliente c1
JOIN cliente c2 ON c1.codcli = c2.cliente_indica
WHERE c1.data_indicacao < '01-01-2018'

-- Para selecionar os dados dessa view:

SELECT * FROM vw_clientes_indicados_antes_2018;

-- Questão #6:

CREATE VIEW vw_clientes_sp_iphone11 AS
SELECT c.nome
FROM cliente c
JOIN ordem_de_compra oc ON c.codcli = oc.codigo_cliente
JOIN compra_produto cp ON oc.codordem = cp.codigo_compra
JOIN produto p ON cp.codigo_produto = p.codprod
WHERE c.END_CIDADE = 'São Paulo' AND p.nome = 'Iphone 11'

-- Para selecionar os dados dessa view:

SELECT * FROM vw_clientes_sp_iphone11;

-- Questão #7:

CREATE OR REPLATE TRIGGER trg_baixa_estoque
AFTER INSERT ON COMPRA_PRODUTO
FOR EACH ROW
BEGIN
   UPDATE produto SET quantidade = quantidade - :NEW.quantidade WHERE codprod = :NEW.codigo_produto;
END;

-- Questão #8:

CREATE OR REPLACE TRIGGER trg_nome_fornecedor
BEFORE INSERT OR UPDATE ON fornecedor
FOR EACH ROW
BEGIN
   :NEW.nome := UPPER(SUBSTR(:NEW.nome, 1, 1)) || SUBSTR(:NEW.nome, 2);
END;

-- Questão #9:

CREATE OR REPLACE TRIGGER trg_end_num
BEFORE INSERT ON cliente
FOR EACH ROW
BEGIN
   IF :NEW.END_NUM = '' OR :NEW.END_NUM = NULL THEN
      :NEW.END_NUM := 's/n';
   END IF;
END;