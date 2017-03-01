view: degrees_of_kevin_bacon {
  derived_table: {
    sql:
      SELECT
        min_degree.degree as degree,

        all.one_degree_movie_title as one_movie_title,
        CASE WHEN min_degree.degree < 2 THEN NULL ELSE all.two_degree_movie_title END as two_movie_title,
        CASE WHEN min_degree.degree < 3 THEN NULL ELSE all.three_degree_movie_title END as three_movie_title,

        one_degree_person_name as one_person_name,
        CASE WHEN min_degree.degree <= 2 THEN NULL ELSE all.two_degree_person_name END as two_person_name,
        CASE WHEN min_degree.degree <= 3 THEN NULL ELSE all.three_degree_person_name END as three_person_name

        FROM ${all_joined2.SQL_TABLE_NAME} as all
        CROSS JOIN (
          SELECT degree FROM ${min_degree.SQL_TABLE_NAME} as min_degree
          WHERE {% condition id_filter %} min_degree.person_id {% endcondition %}
          ) as min_degree

        WHERE
          {% condition id_filter %}
            CASE WHEN min_degree.degree = 1 THEN all.one_degree_person_id
                 WHEN min_degree.degree = 2 THEN all.two_degree_person_id
                 WHEN min_degree.degree = 3 THEN all.three_degree_person_id
            ELSE three_degree_person_id
            END
          {% endcondition %}
      ;;
  }
  filter: id_filter {
    type: number
  }

  dimension: degree {
    type: number
  }

  dimension: one_movie_title {}
  dimension: two_movie_title {}
  dimension: three_movie_title {}
#   dimension: four_movie_id {
#     type: number
#     hidden: yes
#     }
#   dimension: five_movie_id {
#     type: number
#     hidden: yes
#     }
#   dimension: six_movie_id {
#     type: number
#     hidden: yes
#     }

  dimension: one_person_name {}
  dimension: two_person_name {}
  dimension: three_person_name {}
#   dimension: four_person_id {
#     type: number
#     hidden: yes
#     }
#   dimension: five_person_id {
#     type: number
#     hidden: yes
#     }
#   dimension: six_person_id {
#     type: number
#     hidden: yes
#     }
}

explore: all_joined2 {}
view: all_joined2 {
  derived_table: {
    persist_for: "12 hours"
    sql:
      SELECT
        one_degree.movie_title as one_degree_movie_title,
        two_degree.movie_title as two_degree_movie_title,
        three_degree.movie_title as three_degree_movie_title,

        one_degree.person_name as one_degree_person_name,
        two_degree.person_name as two_degree_person_name,
        three_degree.person_name as three_degree_person_name,

        one_degree.person_id as one_degree_person_id,
        two_degree.person_id as two_degree_person_id,
        three_degree.person_id as three_degree_person_id

      FROM ${kb_one_degree.SQL_TABLE_NAME} as one_degree
      LEFT JOIN ${kb_two_degrees.SQL_TABLE_NAME} as two_degree ON one_degree.person_id = two_degree.original_person_id
      LEFT JOIN ${kb_three_degrees.SQL_TABLE_NAME} as three_degree ON two_degree.person_id = three_degree.original_person_id
      ;;
  }

  dimension: movie_title {
    type: number
    sql: ${TABLE}.one_degree_movie_title ;;
  }
}

explore: min_degree {}
view: min_degree {
  derived_table: {
    persist_for: "12 hours"
    sql:
      SELECT
        person_id,
        MIN(degree) as degree
      FROM
        (SELECT person_id, degree FROM ${kb_one_degree.SQL_TABLE_NAME}),
        (SELECT person_id, degree FROM ${kb_two_degrees.SQL_TABLE_NAME}),
        (SELECT person_id, degree FROM ${kb_three_degrees.SQL_TABLE_NAME})
      GROUP BY 1
      ;;
  }

  dimension: person_id {
    type: number
  }

  dimension: degree {
    type: number
  }
}

view: kb_base {
  derived_table: {
    persist_for: "12 hours"
  }

  dimension: degree {
    type: number
  }

  dimension: person_id {
    type: number
  }

  dimension: original_person_id {
    type: number
  }

  dimension: movie_id {
    type: number
  }

  measure: person_count {
    type: count_distinct
    sql: ${person_id} ;;
  }

  measure: movie_count {
    type: count_distinct
    sql: ${movie_id} ;;
  }
}

explore: kb_one_degree {}
view: kb_one_degree {
  extends: [kb_base]
  derived_table: {
    sql:
      SELECT
        1 as degree,
        a.original_person_id as original_person_id,
        a.movie_id as movie_id,
        a.movie_title as movie_title,
        cast_info.person_id as person_id,
        name.name as person_name

      FROM
        (SELECT
          cast_info.person_id as original_person_id,
          cast_info.movie_id as movie_id,
          title.title as movie_title,

        FROM [lookerdata:imdb.cast_info] as cast_info
        LEFT JOIN [lookerdata:imdb.title] as title ON cast_info.movie_id = title.id

        WHERE cast_info.person_id = 98687 AND title.kind_id = 1 AND cast_info.note IS NULL
        GROUP BY 1,2,3) a
      LEFT JOIN [lookerdata:imdb.cast_info] as cast_info ON cast_info.movie_id = a.movie_id
      LEFT JOIN [lookerdata:imdb.name] as name ON cast_info.person_id = name.id
      GROUP BY 1,2,3,4,5,6
      ;;
  }
}

explore: kb_two_degrees {}
view: kb_two_degrees {
  extends: [kb_base]
  derived_table: {
    sql:
      SELECT
        2 as degree,
        a.original_person_id as original_person_id,
        a.movie_id as movie_id,
        a.movie_title as movie_title,
        cast_info.person_id as person_id,
        name.name as person_name

      FROM
        (SELECT
        cast_info.movie_id as movie_id,
        cast_info.person_id as original_person_id,
        title.title as movie_title

        FROM ${kb_one_degree.SQL_TABLE_NAME} as degree
        LEFT JOIN [lookerdata:imdb.cast_info] as cast_info ON degree.person_id = cast_info.person_id
        LEFT JOIN [lookerdata:imdb.title] as title ON cast_info.movie_id = title.id

        WHERE title.kind_id = 1 AND cast_info.note IS NULL
        GROUP BY 1,2,3) a
      LEFT JOIN [lookerdata:imdb.cast_info] as cast_info ON cast_info.movie_id = a.movie_id
      LEFT JOIN [lookerdata:imdb.name] as name ON cast_info.person_id = name.id
      GROUP BY 1,2,3,4,5,6;;
  }
}

explore: kb_three_degrees {}
view: kb_three_degrees {
  extends: [kb_base]
  derived_table: {
    sql:
      SELECT
        3 as degree,
        a.original_person_id as original_person_id,
        a.movie_id as movie_id,
        a.movie_title as movie_title,
        cast_info.person_id as person_id,
        name.name as person_name

      FROM
        (SELECT
        cast_info.movie_id as movie_id,
        cast_info.person_id as original_person_id,
        title.title as movie_title

        FROM ${kb_two_degrees.SQL_TABLE_NAME} as degree
        LEFT JOIN [lookerdata:imdb.cast_info] as cast_info ON degree.person_id = cast_info.person_id
        LEFT JOIN [lookerdata:imdb.title] as title ON cast_info.movie_id = title.id

        WHERE title.kind_id = 1 AND cast_info.note IS NULL
        GROUP BY 1,2,3) a
      LEFT JOIN [lookerdata:imdb.cast_info] as cast_info ON cast_info.movie_id = a.movie_id
      LEFT JOIN [lookerdata:imdb.name] as name ON cast_info.person_id = name.id
      GROUP BY 1,2,3,4,5,6;;
  }
}

explore: kb_four_degrees {}
view: kb_four_degrees {
  extends: [kb_base]
  derived_table: {
    sql:
      SELECT
        4 as degree,
        a.original_person_id as original_person_id,
        a.movie_id as movie_id,
        cast_info.person_id as person_id

      FROM
        (SELECT
        cast_info.movie_id as movie_id,
        cast_info.person_id as original_person_id

        FROM ${kb_three_degrees.SQL_TABLE_NAME} as degree
        LEFT JOIN [lookerdata:imdb.cast_info] as cast_info ON degree.person_id = cast_info.person_id
        LEFT JOIN [lookerdata:imdb.title] as title ON cast_info.movie_id = title.id

        WHERE title.kind_id = 1 AND cast_info.note IS NULL
        GROUP BY 1,2) a
      LEFT JOIN [lookerdata:imdb.cast_info] as cast_info ON cast_info.movie_id = a.movie_id
      GROUP BY 1,2,3,4;;
  }
}

explore: kb_five_degrees {}
view: kb_five_degrees {
  extends: [kb_base]
  derived_table: {
    sql:
      SELECT
        5 as degree,
        a.original_person_id as original_person_id,
        a.movie_id as movie_id,
        cast_info.person_id as person_id

      FROM
        (SELECT
        cast_info.movie_id as movie_id,
        cast_info.person_id as original_person_id

        FROM ${kb_four_degrees.SQL_TABLE_NAME} as degree
        LEFT JOIN [lookerdata:imdb.cast_info] as cast_info ON degree.person_id = cast_info.person_id
        LEFT JOIN [lookerdata:imdb.title] as title ON cast_info.movie_id = title.id

        WHERE title.kind_id = 1 AND cast_info.note IS NULL
        GROUP BY 1,2) a
      LEFT JOIN [lookerdata:imdb.cast_info] as cast_info ON cast_info.movie_id = a.movie_id
      GROUP BY 1,2,3,4;;
  }
}

explore: kb_six_degrees {}
view: kb_six_degrees {
  extends: [kb_base]
  derived_table: {
    sql:
      SELECT
        6 as degree,
        a.original_person_id as original_person_id,
        a.movie_id as movie_id,
        cast_info.person_id as person_id

      FROM
        (SELECT
        cast_info.movie_id as movie_id,
        cast_info.person_id as original_person_id

        FROM ${kb_five_degrees.SQL_TABLE_NAME} as degree
        LEFT JOIN [lookerdata:imdb.cast_info] as cast_info ON degree.person_id = cast_info.person_id
        LEFT JOIN [lookerdata:imdb.title] as title ON cast_info.movie_id = title.id

        WHERE title.kind_id = 1 AND cast_info.note IS NULL
        GROUP BY 1,2) a
      LEFT JOIN [lookerdata:imdb.cast_info] as cast_info ON cast_info.movie_id = a.movie_id
      GROUP BY 1,2,3,4;;
  }
}
