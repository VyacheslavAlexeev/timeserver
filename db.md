>### Likes
>
>Есть таблица likes (user_id: integer, post_id: integer, created_at: datetime, updated_at: datetime)
>В этой таблице порядка нескольких миллионов записей.
>Сервер делает несколько разных запросов по этой таблице, время выполнения этих запросов > 1 sec.
>Запросы:
>```sql
>  SELECT COUNT(*) FROM likes WHERE user_id = ?
>  SELECT COUNT(*) FROM likes WHERE post_id = ?
>  SELECT * FROM likes WHERE user_id = ? AND post_id = ?
>```
>Как узнать почему тормозят запросы, как их можно ускорить (все возможные варианты).

Максимум, что могу сказать:

Поверить тип и наличие индексов. Создать b-tree индексы на поля user_id, post_id, [ user_id, post_id ] (судя по всему, тормозит последний запрос, есть смысл проверить скорость с комбиниорванным индексом).
Если не помогает: курить мануал по EXPLAIN и анализировать запросы.

>### Pending Posts
>Есть такой запрос:
>```sql
>  SELECT * from pending_posts 
>    WHERE user_id <> ?
>      AND NOT approved
>      AND NOT banned
>      AND pending_posts.id NOT IN(
>        SELECT pending_post_id FROM viewed_posts
>          WHERE user_id = ?)
>```
>Какие индексы надо создать и как изменить запрос (если требуется) чтобы запрос работал максимально быстро. 

B-Tree индексы: `pending_posts.user_id`, `viewed_posts.user_id`, `viewed_posts.pending_post_id`

Запрос:
```sql
  SELECT * from pending_posts 
    INNER JOIN viewed_posts ON viewed_posts.user_id = pending_posts.user_id
    WHERE user_id <> ?
      AND NOT approved
      AND NOT banned
      AND pending_posts.id <> viewed_posts.pending_post_id
```
