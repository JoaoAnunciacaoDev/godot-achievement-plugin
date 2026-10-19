# 🏆 Achievement System — Plugin para Godot 4

Um sistema de conquistas completo desenvolvido para **Godot 4.7**. 

Com suporte a **conquistas simples**, **cumulativas (com progresso)**, **conquistas secretas (anti-spoiler)**, **fila de notificações** e **persistência automática em JSON**.

---

## Funcionalidades (Features)

* **Plug & Play:** Ao ativar o plugin, os Singletons (`AchievementsManager` e `AchievementNotification`) são registrados automaticamente nos Autoloads do projeto.
* **Conquistas Simples & Cumulativas:**
  * **Simples:** Desbloqueiadas de uma só vez via `unlock()`.
  * **Cumulativas:** Metas incrementais (ex: *"Colete 5 colecionáveis"*) via `increment()`, com barra de progresso visual ao redor do ícone.
* **Conquistas Secretas (Anti-Spoiler):**
  * Oculte o nome e a descrição de conquistas com segredos de história com a flag `is_secret`. O nome real e a descrição são revelados apenas no momento, e após o desbloqueio!
* **Fila de Notificações (Até 3 simultâneas):**
  * Popups alinhados verticalmente via Vbox.
  * Se o jogador conquistar múltiplos objetivos ao mesmo tempo, até 3 notificações sobem empilhadas na tela. Se houver mais, elas aguardam na fila e entram automaticamente quando abrir espaço.
* **Carregamento Automático por Pasta:**
  * O gerenciador varre automaticamente uma pasta configurável do projeto (`res://...`) para carregar todos os recursos `.tres` na inicialização, eliminando a necessidade de arrastar arquivos manualmente no Inspector.
* **Persistência Automática em JSON:**
  * Progresso e desbloqueios são salvos e carregados automaticamente em `user://achievements.json`.
* **Tema Customizável (`Theme`):**
  * Totalmente integrado ao sistema de temas nativo da Godot com *Type Variations*. Troque fontes, tamanhos e cores em um minuto para combinar com o estilo do seu jogo.
* **Segurança contra Erros de Digitação:**
  * Suporte a classe com constantes (`AchievementIDs`) para autocompletar e validação pelo compilador da Godot.

---

## Instalação

1. Copie a pasta **`addons/achievements_system/`** para dentro da pasta do seu projeto Godot.
   ```text
   SeuJogo/
   └── addons/
       └── achievements_system/
           ├── plugin.cfg
           └── ...
   ```
2. No editor da Godot, acesse: **Projeto → Configurações do Projeto → Plugins**.
3. Encontre o **AchievementSystem** e marque a caixa **Ativar (Enable)**.
4. *Pronto!* Os Autoloads `AchievementsManager` e `AchievementNotification` já estão configurados e prontos para uso em qualquer cena.

---

## Como Criar Conquistas

1. No painel **FileSystem**, clique com o botão direito na pasta onde deseja guardar suas conquistas (ex: `res://achievements/`, lembre-se de alterar o path da pasta no AchievementsManager) → **Criar Novo → Recurso...**
2. Procure por **`Achievement`** e salve como `.tres` (ex: `primeiro_passo.tres`).
3. No **Inspector**, preencha os campos:

| Campo | Tipo | Descrição |
|---|---|---|
| `id` | `String` | Identificador único da conquista (ex: `"first_death"`). |
| `achievement_name` | `String` | Nome de exibição da conquista. |
| `description` | `String` | Descrição ou objetivo da conquista. |
| `unlocked_icon` | `Texture2D` | Ícone exibido quando a conquista for desbloqueada. |
| `locked_icon` | `Texture2D` | Ícone exibido enquanto a conquista estiver bloqueada. |
| `is_cumulative` | `bool` | Marque como `true` se a conquista precisar de múltiplos passos para ser concluída. |
| `max_progress` | `int` | Quantidade de passos necessários (usado apenas se `is_cumulative = true`). |
| `is_secret` | `bool` | Marque como `true` para ocultar o nome e a descrição na galeria enquanto bloqueada. |
| `secret_description` | `String` | Texto exibido no lugar da descrição enquanto a conquista secreta estiver bloqueada. |

---

## Como Usar via Código

### 1. Usar o Script de Constantes (`AchievementIDs`)
Para ter autocompletar na IDE e evitar erros de digitação, use o script preenchendo os nomes das suas conquistas apenas uma vez, evitando erros de digitação no futuro, você encontrará nos arquivos algo assim:

```gdscript
class_name AchievementIDs

const FIRST_STEP        := "first_step"
const COLLECT_COINS     := "collect_coins"
const SECRET_TREASURE   := "secret_treasure"
```

### 2. Desbloquear Conquistas
```gdscript
# Desbloqueia uma conquista simples:
AchievementsManager.unlock(AchievementIDs.FIRST_STEP)

# Incrementa o passo de uma conquista cumulativa:
AchievementsManager.increment(AchievementIDs.COLLECT_COINS)

# Quando o contador atingir o max_progress, o sistema faz o desbloqueio final sozinho!
```

### 3. Consultar Estado e Progresso
```gdscript
# Saber se uma conquista já foi desbloqueada:
if AchievementsManager.is_unlocked(AchievementIDs.FIRST_STEP):
    print("Conquista já concluída!")

# Obter o progresso atual de uma cumulativa:
var atual: int = AchievementsManager.get_progress(AchievementIDs.COLLECT_COINS)

# Obter o valor máximo necessário:
var maximo: int = AchievementsManager.get_max_progress(AchievementIDs.COLLECT_COINS)
```

### 4. Resetar Progresso (para Testes/Debug)
```gdscript
# Zera todas as conquistas e progressos e salva o JSON limpo:
AchievementsManager.reset_all()
```

### 5. Sinais Disponíveis (`AchievementsManager`)
```gdscript
# Disparado quando uma conquista é totalmente desbloqueada:
AchievementsManager.achievement_unlocked.connect(func(data: Achievement):
    print("Conquista concluída: ", data.achievement_name)
)

# Disparado a cada incremento parcial de uma conquista cumulativa:
AchievementsManager.achievement_progress.connect(func(data: Achievement, current: int, max_val: int):
    print("Progresso em %s: %d/%d" % [data.achievement_name, current, max_val])
)
```

---

## Criando uma Galeria de Conquistas (Menu)

Você pode criar uma tela de menu de conquistas usando a cena `achievement_cell.tscn` fornecida pelo plugin, nos arquivos também está presente um exemplo de menu de conquistas (`achievements_menu.tscn`), use para entender como usar.

---

## Personalização de Estilo e Temas

O plugin utiliza o arquivo **`addons/achievements_system/theme/achievements_theme.tres`**. 

Você pode abrir esse arquivo e personalizar facilmente:
* **`achievementTitle`** (Base: `Label`): Fonte, tamanho e cor do título da conquista.
* **`achievementDescription`** (Base: `Label`): Fonte e cor da descrição do objetivo.
* **`achievementUnlock`** (Base: `Label`): Estilo do rótulo em destaque (`ACHIEVEMENT UNLOCKED` / `PROGRESS: X/Y`).
* **`achievementCell`** (Base: `PanelContainer`): Fundo e bordas do cartão principal.
* **`achievementIconBg`** (Base: `PanelContainer`): Moldura de fundo do ícone.
* **`achievementAccent`** (Base: `PanelContainer`): Barrinha de destaque lateral.

---

## Efeitos Sonoros (SFX)

* **Som Padrão do Plugin:** No nó `AchievementNotification`, você pode atribuir um arquivo de áudio no campo **Unlock Sound** do Inspector.
* **Usando o seu próprio Gerenciador de Som (ex: `SfxManager`):**  
  Deixe o campo `Unlock Sound` vazio e conecte o sinal em qualquer script do seu jogo:
  ```gdscript
  AchievementsManager.achievement_unlocked.connect(func(_ach):
      SfxManager.play_sfx("conquista_desbloqueada")
  )
  ```

---

## Arquivo de Save

O progresso é salvo automaticamente em:
`user://achievements.json`

Estrutura do arquivo:
```json
{
  "unlocked": ["first_step", "secret_treasure"],
  "progress": {
    "collect_coins": 3
  }
}
```