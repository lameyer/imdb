explore: kb_one_degree {}

view: kb_base {
  derived_table: {
    persist_for: "12 hours"
  }

  dimension: person_id {}
  dimension: movie_id {}

  measure: person_count {
    type: count_distinct
    sql: ${person_id} ;;
  }

  measure: movie_count {
    type: count_distinct
    sql: ${movie_id} ;;
  }
}

view: kb_one_degree {
  extends: [kb_base]
  derived_table: {
    sql:
      SELECT
        a.movie_id as movie_id,
        a.title as title,
        cast_info.person_id as person_id

      FROM
        (SELECT
        cast_info.movie_id as movie_id,
        title.title as title

        FROM [lookerdata:imdb.cast_info] as cast_info
        LEFT JOIN [lookerdata:imdb.title] as title ON cast_info.movie_id = title.id

        WHERE cast_info.person_id = 98687 AND title.kind_id = 1
        GROUP BY 1,2) a
      LEFT JOIN [lookerdata:imdb.cast_info] as cast_info ON cast_info.movie_id = a.movie_id
      GROUP BY 1,2,3
      ;;
  }

  dimension: title {}
}

explore: kb_two_degrees {}

view: kb_two_degrees {
  extends: [kb_base]
  derived_table: {
    sql:
      SELECT
        a.movie_id as movie_id,
        cast_info.person_id as person_id

      FROM
        (SELECT
        cast_info.movie_id as movie_id

        FROM ${kb_one_degree.SQL_TABLE_NAME} as degree
        LEFT JOIN [lookerdata:imdb.cast_info] as cast_info ON degree.person_id = cast_info.person_id
        LEFT JOIN [lookerdata:imdb.title] as title ON cast_info.movie_id = title.id

        WHERE title.kind_id = 1
        GROUP BY 1) a
      LEFT JOIN [lookerdata:imdb.cast_info] as cast_info ON cast_info.movie_id = a.movie_id
      GROUP BY 1,2;;
  }
}

explore: kb_three_degrees {}
view: kb_three_degrees {
  extends: [kb_base]
  derived_table: {
    sql:
      SELECT
        a.movie_id as movie_id,
        cast_info.person_id as person_id

      FROM
        (SELECT
        cast_info.movie_id as movie_id

        FROM ${kb_two_degrees.SQL_TABLE_NAME} as degree
        LEFT JOIN [lookerdata:imdb.cast_info] as cast_info ON degree.person_id = cast_info.person_id
        LEFT JOIN [lookerdata:imdb.title] as title ON cast_info.movie_id = title.id

        WHERE title.kind_id = 1
        GROUP BY 1) a
      LEFT JOIN [lookerdata:imdb.cast_info] as cast_info ON cast_info.movie_id = a.movie_id
      GROUP BY 1,2;;
  }
}

explore: kb_four_degrees {}
view: kb_four_degrees {
  extends: [kb_base]
  derived_table: {
    sql:
      SELECT
        a.movie_id as movie_id,
        cast_info.person_id as person_id

      FROM
        (SELECT
        cast_info.movie_id as movie_id

        FROM ${kb_three_degrees.SQL_TABLE_NAME} as degree
        LEFT JOIN [lookerdata:imdb.cast_info] as cast_info ON degree.person_id = cast_info.person_id
        LEFT JOIN [lookerdata:imdb.title] as title ON cast_info.movie_id = title.id

        WHERE title.kind_id = 1
        GROUP BY 1) a
      LEFT JOIN [lookerdata:imdb.cast_info] as cast_info ON cast_info.movie_id = a.movie_id
      GROUP BY 1,2;;
  }
}

explore: kb_five_degrees {}
view: kb_five_degrees {
  extends: [kb_base]
  derived_table: {
    sql:
      SELECT
        a.movie_id as movie_id,
        cast_info.person_id as person_id

      FROM
        (SELECT
        cast_info.movie_id as movie_id

        FROM ${kb_four_degrees.SQL_TABLE_NAME} as degree
        LEFT JOIN [lookerdata:imdb.cast_info] as cast_info ON degree.person_id = cast_info.person_id
        LEFT JOIN [lookerdata:imdb.title] as title ON cast_info.movie_id = title.id

        WHERE title.kind_id = 1
        GROUP BY 1) a
      LEFT JOIN [lookerdata:imdb.cast_info] as cast_info ON cast_info.movie_id = a.movie_id
      GROUP BY 1,2;;
  }
}

explore: kb_six_degrees {}
view: kb_six_degrees {
  extends: [kb_base]
  derived_table: {
    sql:
      SELECT
        a.movie_id as movie_id,
        cast_info.person_id as person_id

      FROM
        (SELECT
        cast_info.movie_id as movie_id

        FROM ${kb_five_degrees.SQL_TABLE_NAME} as degree
        LEFT JOIN [lookerdata:imdb.cast_info] as cast_info ON degree.person_id = cast_info.person_id
        LEFT JOIN [lookerdata:imdb.title] as title ON cast_info.movie_id = title.id

        WHERE title.kind_id = 1
        GROUP BY 1) a
      LEFT JOIN [lookerdata:imdb.cast_info] as cast_info ON cast_info.movie_id = a.movie_id
      GROUP BY 1,2;;
  }
}
