# SELLERAPP


# Task

Adicionar campos novos e alterar o formato do arquivo para xslx

- Descrição
- ISBN
- CPF / CNPJ
- Destinatário
- Endereço
- Logradouro
- Número
- Complemento
- Bairro
- UF
- CEP
- código de rastreio
- link de rastreio

## Atual situação

- Condicionais para fluxos diferentes
- Classe com baixa coesão (com várias responsabilidades e baixa reusabilidade)
- Classe grande (com muitas linhas)
- Design com testabilidade prejudicada
- Um mal exemplo para replicar

## Refatorado

- Baixo acoplamento (delega a responsabilidade/tarefa para outros)
- Alta coesão (uma única responsabilidade)
- Classes menores, mais simples de entender
- Melhora na testabilidade (separação)
- OCP - Classe aberta para extensão (extender o comportamento é fácil) e fechada para modificação (não é necessário alterar o código da classe)
- Bom exemplo para replicar (Sandi Metz)

