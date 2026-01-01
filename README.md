# 🎓 Sistema de Gestão Escolar

![Status](https://img.shields.io/badge/Status-Em_Produção-yellow)
![Java](https://img.shields.io/badge/Java-21-ED8B00?style=flat&logo=openjdk&logoColor=white)
![Spring Boot](https://img.shields.io/badge/Spring_Boot-3.x-6DB33F?style=flat&logo=spring&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat&logo=flutter&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?style=flat&logo=mysql&logoColor=white)

> **TCC:** Trabalho de Conclusão de Curso - Fatec Zona Leste

## 📄 Sobre o Projeto

O **Sistema de Gestão Escolar** é uma solução completa desenvolvida para facilitar a administração de instituições de ensino. O sistema resolve o problema da descentralização de informações, permitindo o gerenciamento integrado de múltiplas escolas, turmas, disciplinas, alunos e seus responsáveis.

O projeto consiste em uma **API REST robusta** no back-end e um aplicativo móvel/web responsivo no front-end.

## 🎯 Funcionalidades Principais

* ✅ **Gestão Multi-Escolas:** Cadastro e administração de diferentes unidades escolares.
* ✅ **Controle Acadêmico:** Gerenciamento completo de Disciplinas e Turmas (séries, turnos).
* ✅ **Gestão de Pessoas:** Cadastro detalhado de Alunos e Responsáveis (com vínculo familiar).
* ✅ **Matrículas Inteligentes:** Sistema de alocação de alunos em turmas, com validação de regras de negócio (ex: não permitir duplicidade de matrícula).
* ✅ **Segurança:** Back-end preparado com Spring Security e criptografia de senhas.

## 📱 Layout / Demonstração

| Tela Inicial | Lista de Alunos | Detalhes da Turma |
|:---:|:---:|:---:|
| *(Insira aqui o print da Home)* | *(Insira aqui o print da Lista)* | *(Insira aqui o print do Detalhe)* |

## 🛠️ Tecnologias Utilizadas

Este projeto full-stack utiliza as tecnologias mais modernas do mercado:

**Back-end (API REST):**
* **Linguagem:** Java 21
* **Framework:** Spring Boot 3.5.6
* **Dados:** Spring Data JPA & MySQL
* **Documentação:** Swagger (SpringDoc OpenAPI)
* **Ferramentas:** Maven, Lombok, ModelMapper

**Front-end (Mobile/Web):**
* **Framework:** Flutter & Dart
* **Comunicação:** Pacote `http` para consumo de APIs REST
* **Arquitetura:** Padrão Service-Repository para separação de regras de negócio e UI.

## 🏗️ Arquitetura e Modelagem

O sistema foi desenvolvido seguindo boas práticas de engenharia de software:

1.  **Back-end em Camadas:**
    * **Controller:** Pontos de entrada da API (REST).
    * **Service:** Regras de negócio e validações (ex: `TurmaService`, `AlunoService`).
    * **Repository:** Abstração de acesso a dados (Hibernate/JPA).
    * **DTOs:** Objetos de transferência de dados para segurança e desacoplamento.

2.  **Banco de Dados Relacional:**
    * Relacionamentos N:N (Turmas <-> Alunos).
    * Relacionamentos 1:N (Escola <-> Alunos, Responsável <-> Alunos).

## 🚀 Como executar o projeto

### Pré-requisitos
* Java JDK 21
* Flutter SDK
* MySQL Server (Rodando na porta 3306)

### 1. Back-end (Servidor)

```bash
# Clone o repositório e acesse a pasta backend
$ cd backend

# Configure o banco de dados no arquivo application.properties
# (Certifique-se de criar um banco chamado 'sistema_gestao_escolar')

# Execute a aplicação
$ ./mvnw spring-boot:run

O servidor iniciará em http://localhost:8081 Documentação da API (Swagger): http://localhost:8081/swagger-ui.html
```

### 2. Front-end (App)
````Bash

# Acesse a pasta frontend
$ cd frontend

# Instale as dependências
$ flutter pub get

# Execute o aplicativo
$ flutter run
````
## 👥 Autores

* **Eduardo Santana** - [GitHub](https://github.com/EduardoHSantana)
* **Iago Barros** - [GitHub](https://github.com/iagobarross)
* **J. Marcos** - [GitHub](https://github.com/J-Marcos01)
