view: name {
  derived_table: {
    persist_for: "500 hours"
    sql:
      SELECT
        *
        , CONCAT(first_name, ' ', last_name) as person_name
        FROM (
          SELECT
            *
            , FIRST(SPLIT(name.name,', ')) AS last_name
            , NTH(2,SPLIT(name.name,', ')) as first_name
          FROM [lookerdata:imdb.name]
        ) as n
       ;;
  }

  dimension: id {
    label: "Person ID"
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: gender {
    sql: ${TABLE}.gender ;;
  }

  dimension: name {
    sql: ${TABLE}.person_name ;;
  }

  dimension: last_name {}
  dimension: first_name {}

  dimension: imdb_id {
    type: number
    sql: ${TABLE}.imdb_id ;;
    hidden: yes
  }

  dimension: imdb_index {
    sql: ${TABLE}.imdb_index ;;
    hidden: yes
  }

  dimension: md5sum {
    sql: ${TABLE}.md5sum ;;
    hidden: yes
  }

  dimension: person_name {
    sql: ${TABLE}.person_name ;;
  }

  dimension: name_pcode_cf {
    sql: ${TABLE}.name_pcode_cf ;;
    hidden: yes
  }

  dimension: name_pcode_nf {
    sql: ${TABLE}.name_pcode_nf ;;
    hidden: yes
  }

  dimension: surname_pcode {
    sql: ${TABLE}.surname_pcode ;;
    hidden: yes
  }

  measure: person_count {
    type: count
    drill_fields: [id, person_name, gender, title.count]
  }
}
