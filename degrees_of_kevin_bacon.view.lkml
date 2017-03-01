view: degrees_of_kevin_bacon {
  derived_table: {
    sql:
      SELECT
        one_degree.movie_id as one_movie_id,
        CASE WHEN min_degree.degree < 2 THEN NULL ELSE two_degree.movie_id END as two_movie_id,
        CASE WHEN min_degree.degree < 3 THEN NULL ELSE three_degree.movie_id END as three_movie_id,
        CASE WHEN min_degree.degree < 4 THEN NULL ELSE four_degree.movie_id END as four_movie_id,
        CASE WHEN min_degree.degree < 5 THEN NULL ELSE five_degree.movie_id END as five_movie_id,
        CASE WHEN min_degree.degree < 6 THEN NULL ELSE six_degree.movie_id END as six_movie_id,

        one_degree.person_id as one_person_id,
        CASE WHEN min_degree.degree <= 2 THEN NULL ELSE two_degree.person_id END as two_person_id,
        CASE WHEN min_degree.degree <= 3 THEN NULL ELSE three_degree.person_id END as three_person_id,
        CASE WHEN min_degree.degree <= 4 THEN NULL ELSE four_degree.person_id END as four_person_id,
        CASE WHEN min_degree.degree <= 5 THEN NULL ELSE five_degree.person_id END as five_person_id,
        CASE WHEN min_degree.degree <= 6 THEN NULL ELSE six_degree.person_id END as six_person_id

        FROM ${kb_one_degree.SQL_TABLE_NAME} as one_degree
        LEFT JOIN ${kb_two_degrees.SQL_TABLE_NAME} as two_degree ON one_degree.person_id = two_degree.original_person_id
        LEFT JOIN ${kb_three_degrees.SQL_TABLE_NAME} as three_degree ON two_degree.person_id = three_degree.original_person_id
        LEFT JOIN ${kb_four_degrees.SQL_TABLE_NAME} as four_degree ON three_degree.person_id = four_degree.original_person_id
        LEFT JOIN ${kb_five_degrees.SQL_TABLE_NAME} as five_degree ON four_degree.person_id = five_degree.original_person_id
        LEFT JOIN ${kb_six_degrees.SQL_TABLE_NAME} as six_degree ON five_degree.person_id = six_degree.original_person_id

        CROSS JOIN (
          SELECT degree FROM ${min_degree.SQL_TABLE_NAME} as min_degree
          WHERE {% condition id_filter %} min_degree.person_id {% endcondition %}
          ) as min_degree

        WHERE

          {% condition id_filter %}
            CASE WHEN min_degree.degree = 1 THEN one_degree.person_id
                 WHEN min_degree.degree = 2 THEN two_degree.person_id
                 WHEN min_degree.degree = 3 THEN three_degree.person_id
                 WHEN min_degree.degree = 4 THEN four_degree.person_id
                 WHEN min_degree.degree = 5 THEN five_degree.person_id
                 WHEN min_degree.degree = 5 THEN six_degree.person_id
            ELSE three_degree.person_id
            END
          {% endcondition %}
      ;;
  }
  filter: id_filter {
    type: number
  }

  dimension: one_movie_id {
    type: number
    hidden: yes
  }
  dimension: two_movie_id {
    type: number
    hidden: yes
    }
  dimension: three_movie_id {
    type: number
    hidden: yes
    }
  dimension: four_movie_id {
    type: number
    hidden: yes
    }
  dimension: five_movie_id {
    type: number
    hidden: yes
    }
  dimension: six_movie_id {
    type: number
    hidden: yes
    }

  dimension: one_person_id {
    type: number
    hidden: yes
    }
  dimension: two_person_id {
    type: number
    hidden: yes
    }
  dimension: three_person_id {
    type: number
    hidden: yes
    }
  dimension: four_person_id {
    type: number
    hidden: yes
    }
  dimension: five_person_id {
    type: number
    hidden: yes
    }
  dimension: six_person_id {
    type: number
    hidden: yes
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
        ${kb_one_degree.SQL_TABLE_NAME},
        ${kb_two_degrees.SQL_TABLE_NAME},
        ${kb_three_degrees.SQL_TABLE_NAME}
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
        cast_info.person_id as person_id

      FROM
        (SELECT
          cast_info.person_id as original_person_id,
          cast_info.movie_id as movie_id

        FROM [lookerdata:imdb.cast_info] as cast_info
        LEFT JOIN [lookerdata:imdb.title] as title ON cast_info.movie_id = title.id

        WHERE cast_info.person_id = 98687 AND title.kind_id = 1 AND cast_info.note IS NULL
        GROUP BY 1,2) a
      LEFT JOIN [lookerdata:imdb.cast_info] as cast_info ON cast_info.movie_id = a.movie_id
      GROUP BY 1,2,3,4
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
        cast_info.person_id as person_id

      FROM
        (SELECT
        cast_info.movie_id as movie_id,
        cast_info.person_id as original_person_id

        FROM ${kb_one_degree.SQL_TABLE_NAME} as degree
        LEFT JOIN [lookerdata:imdb.cast_info] as cast_info ON degree.person_id = cast_info.person_id
        LEFT JOIN [lookerdata:imdb.title] as title ON cast_info.movie_id = title.id

        WHERE title.kind_id = 1 AND cast_info.note IS NULL
        GROUP BY 1,2) a
      LEFT JOIN [lookerdata:imdb.cast_info] as cast_info ON cast_info.movie_id = a.movie_id
      GROUP BY 1,2,3,4;;
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
        cast_info.person_id as person_id

      FROM
        (SELECT
        cast_info.movie_id as movie_id,
        cast_info.person_id as original_person_id

        FROM ${kb_two_degrees.SQL_TABLE_NAME} as degree
        LEFT JOIN [lookerdata:imdb.cast_info] as cast_info ON degree.person_id = cast_info.person_id
        LEFT JOIN [lookerdata:imdb.title] as title ON cast_info.movie_id = title.id

        WHERE title.kind_id = 1 AND cast_info.note IS NULL
        GROUP BY 1,2) a
      LEFT JOIN [lookerdata:imdb.cast_info] as cast_info ON cast_info.movie_id = a.movie_id
      GROUP BY 1,2,3,4;;
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
