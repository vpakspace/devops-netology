# Инструменты Git — археология в репозитории Terraform

Домашнее задание по утилитам Git. Исследование истории клонированного репозитория
[hashicorp/terraform](https://github.com/hashicorp/terraform).

```bash
git clone https://github.com/hashicorp/terraform.git
cd terraform
```

---

## 1. Полный хеш и комментарий коммита, начинающегося на `aefea`

```bash
git log -1 --format='%H%n%s' aefea
```

Git сам разрешает сокращённый хеш до полного.

- **Полный хеш:** `aefead2207ef7e2aa5dc81a34aedf0cad4c32545`
- **Комментарий:** `Update CHANGELOG.md`

---

## 2. Какому тегу соответствует коммит `85024d3`?

```bash
git tag --points-at 85024d3      # тег, указывающий ровно на этот коммит
git describe --tags 85024d3      # ближайший тег
```

Оба способа дают один результат.

- **Тег:** `v0.12.23`

---

## 3. Сколько родителей у коммита `b8d720`? Их хеши

```bash
git log -1 --format='%H%nparents=%P' b8d720
```

В поле `%P` перечислены хеши всех родителей. Их два — значит, это **merge-коммит**.

- **Родителей:** 2
- **Хеши родителей:**
  - `56cd7859e05c36c06b56d013b55a252d0bb7e158`
  - `9ea88f22fc6269854151c571162c5bcf958bee2b`

---

## 4. Коммиты между тегами `v0.12.23` и `v0.12.24`

```bash
git log --oneline v0.12.23..v0.12.24
```

Запись `A..B` означает «коммиты, достижимые из `B`, но не из `A`», то есть всё, что
вошло в `v0.12.24` после `v0.12.23` (сам `v0.12.23` исключён, `v0.12.24` включён).

| Хеш | Комментарий |
|-----|-------------|
| `33ff1c03bb` | v0.12.24 |
| `b14b74c493` | [Website] vmc provider links |
| `3f235065b9` | Update CHANGELOG.md |
| `6ae64e247b` | registry: Fix panic when server is unreachable |
| `5c619ca1ba` | website: Remove links to the getting started guide's old location |
| `06275647e2` | Update CHANGELOG.md |
| `d5f9411f51` | command: Fix bug when using terraform login on Windows |
| `4b6d06cc5d` | Update CHANGELOG.md |
| `dd01a35078` | Update CHANGELOG.md |
| `225466bc3e` | Cleanup after v0.12.23 release |

---

## 5. Коммит, в котором была создана функция `func providerSource(...)`

Используем «pickaxe»-поиск по содержимому изменений (`-S` ищет коммиты, где менялось
количество вхождений строки), а `--reverse` ставит самый ранний коммит первым:

```bash
git log -S'func providerSource(' --oneline --reverse -- '*.go' | head -1
```

- **Коммит:** `8c928e83589d90a031f811fae52a81be7153e82f`
- **Комментарий:** `main: Consult local directories as potential mirrors of providers`
- **Автор / дата:** Martin Atkins, 2020-04-02

---

## 6. Все коммиты, в которых изменялась функция `globalPluginDirs`

`-G` показывает все коммиты, в diff которых встречается данная строка (то есть где
тело/вызов функции реально менялись):

```bash
git log --oneline -G'globalPluginDirs' -- '*.go'
```

| Хеш | Комментарий |
|-----|-------------|
| `7c4aeac5f3` | stacks: load credentials from config file on startup (#35952) |
| `22a2580e93` | main: Use the new cliconfig package credentials source |
| `35a058fb3d` | main: configure credentials from the CLI config file |
| `c0b1761096` | prevent log output during init |
| `8364383c35` | Push plugin discovery down into command package |

Самый ранний (`8364383c35`) — коммит, в котором функция была **создана**.

---

## 7. Кто автор функции `synchronizedWriters`?

Находим самый ранний коммит, добавивший функцию, и смотрим его автора:

```bash
git log -S'func synchronizedWriters(' --reverse \
  --format='%an <%ae> | %ad | %s' --date=short -- '*.go' | head -1
```

- **Коммит создания:** `5ac311e2a91e381e2f52234668b49ba670aa0fe5`
  («main: synchronize writes to VT100-faker on Windows», 2017-05-03)
- **Автор:** **Martin Atkins** `<mart@degeneration.co.uk>`

(Более поздний коммит `bdfea50cc8` от James Bardin лишь удалил неиспользуемый код —
авторство самой функции принадлежит Martin Atkins.)
