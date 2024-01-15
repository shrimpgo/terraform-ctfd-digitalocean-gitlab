# Introdução

Este repositório possui códigos de Terraform para subir a infraestrutura de CTFd da BHack na Digital Ocean (DO), nos conceitos de IoC (Infrastructure as Code). O código está dividido em duas etapas:

* Cluster Kubernetes + Container Registry
* Todas as configurações do Kubernetes:
  * external-dns - registra automaticamente as solicitações para o servidor DNS (Cloudflare)
  * cert-manager - gerencia os certificados em uma cadeia PKI (Let's Encrypt)
  * nginx-controller - proxy reverso que faz a "ponte" entre o cluster e o Load Balancer
  * CTFd - servidor web de CTF
  * Cópia das customizações do evento BHack

## Conceitos básicos de Terraform

Sendo mais direto, Terraform possui 4 etapas:

- **Validate**: valida a sintaxe do código Terraform e a formatação
- **Plan**: mostra tudo que vai ser aplicado em comparação com o estado salvo (state)
- **Apply**: aplica o *Plan*
- **Destroy**: desfaz tudo que foi aplicado em *Apply*

Todas as modificações que o Terraform faz, ele grava em um arquivo com a extensão .tfstate. No nosso caso, esse arquivo está registrado dentro do GitLab. Portanto, se esse arquivo é destruído, o Terraform não tem como descobrir o estado atual do que ele foi proposto a configurar.

Outros detalhes como *providers*, *backend* etc. deixarei documentado dentro dos arquivos .tf.

# Disparando a pipeline

Para que o código seja aplicado, existem três condições:

* Criação da infraestrutura
* Alteração das configurações da infraestrutura
* Removendo a infraestrutura

Antes de realizar qualquer alteração, sugiro instalar o Terraform localmente, pois em alguns momentos é necessário realizar alterações via comando. Ex.: na etapa *Validate*, o Terraform roda um comando para verificar se o código tá formatado. Caso falhe, a pipeline toda falhará. Se acontecer, basta executar na raiz do projeto:

`$ terraform fmt -recursive`

E realizar o push novamente para o repositório via Git.
## Criação da infraestrutura

* No menu à esquerda do projeto, clique em *CI/CD*, depois *Pipeline* e clique no botão *Run Pipeline*
![Run Pipeline](run_pipeline-1.png)
* Depois clique em *Run Pipeline* outra vez. A branch deve ser SEMPRE a main
![Run Pipeline](run_pipeline-2.png)
* A pipeline será disparada seguindo as etapas do Terraform. O primeiro *trigger* é acionado (cluster) e dentro dele há outros jobs de Terraform (mencionados acima). As etapas *Validate* e *Plan* são automáticas, porém as etapas *Apply* e *Destroy* são manuais. A *trigger* config só será disparada se o *trigger* cluster terminar, ou seja, se a etapa *Apply* for executada. Neste caso, basta clicar no símbolo de play para iniciar a aplicação:
![Apply](trigger_apply.png)
* Para verificar o andamento do processo, basta clicar em uma das etapas para analisar. Qualquer erro, a pipeline irá avisar.

## Alteração das configurações da infraestrutura

Toda alteração nas configurações da infraestrutura é realizada fazendo o pull do repositório, modificando as configurações e depois fazendo o push para a branch main. Se fizer em outra branch, a pipeline não é disparada. Qualquer alteração segue o fluxo `Validate -> Plan -> Apply/Destroy`. Neste caso, jamais dispare o *Destroy* (por questões óbvias).

## Desfazendo a infraestrutura

Como já é sabido, o job *Destroy* já é criado durante à criação/alteração da infraestrutura. Neste caso, basta clicar no job para iniciar a remoção das configurações.

**Obs.:** o processo SEMPRE deve seguir o fluxo `config -> cluster`, pois se iniciar a remoção pelo cluster primeiro, além de não ser mais possível executar o job pela *trigger* config (são relacionados às configurações do Kubernetes), na DO ainda vai constar alguns recursos habilitados como o volume criado e os Load Balancers, podendo gerar custos ao responsável pelo pagamento da DO (Adriano).

# TODO List

* Colocar na pipeline o deploy inicial de todos os desafios
* Criar template charts para os desafios (facilitaria nas configurações)
* Criar pipeline para build e deploy dos desafios alterados via código-fonte