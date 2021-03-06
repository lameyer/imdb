connection: "bigquery_publicdata"

label: "IMDB BigQuery"

# include all the views
include: "*.view"

# include all the dashboards
include: "*.dashboard"

case_sensitive: no

view: title_table_name {
  sql_table_name: imdb.title ;;
}

explore: name {}

explore: degrees_of_kevin_bacon {
#   join: one_degree_person {
#     view_label: "1st Degree"
#     from: name
#     fields: [name]
#     sql_on: ${degrees_of_kevin_bacon.one_person_id} = ${one_degree_person.id} ;;
#   }
#   join: two_degree_person {
#     view_label: "2nd Degree"
#     from: name
#     fields: [name]
#     sql_on: ${degrees_of_kevin_bacon.two_person_id} = ${two_degree_person.id} ;;
#   }
#   join: three_degree_person {
#     view_label: "3rd Degree"
#     from: name
#     fields: [name]
#     sql_on: ${degrees_of_kevin_bacon.three_person_id} = ${three_degree_person.id} ;;
#   }
#   join: four_degree_person {
#     view_label: "4th Degree"
#     from: name
#     fields: [name]
#     sql_on: ${degrees_of_kevin_bacon.four_person_id} = ${four_degree_person.id} ;;
#   }
#   join: five_degree_person {
#     view_label: "5th Degree"
#     from: name
#     fields: [name]
#     sql_on: ${degrees_of_kevin_bacon.five_person_id} = ${five_degree_person.id} ;;
#   }
#   join: six_degree_person {
#     view_label: "6th Degree"
#     from: name
#     fields: [name]
#     sql_on: ${degrees_of_kevin_bacon.six_person_id} = ${six_degree_person.id} ;;
#   }

#   join: one_degree_movie {
#     view_label: "1st Degree"
#     from: title
#     fields: [title]
#     sql_on: ${degrees_of_kevin_bacon.one_movie_id} = ${one_degree_movie.id} ;;
#   }
#   join: two_degree_movie {
#     view_label: "2nd Degree"
#     from: title
#     fields: [title]
#     sql_on: ${degrees_of_kevin_bacon.two_movie_id} = ${two_degree_movie.id} ;;
#   }
#   join: three_degree_movie {
#     view_label: "3rd Degree"
#     from: title
#     fields: [title]
#     sql_on: ${degrees_of_kevin_bacon.three_movie_id} = ${three_degree_movie.id} ;;
#   }
#   join: four_degree_movie {
#     view_label: "4th Degree"
#     from: title
#     fields: [title]
#     sql_on: ${degrees_of_kevin_bacon.four_movie_id} = ${four_degree_movie.id} ;;
#   }
#   join: five_degree_movie {
#     view_label: "5th Degree"
#     from: title
#     fields: [title]
#     sql_on: ${degrees_of_kevin_bacon.five_movie_id} = ${five_degree_movie.id} ;;
#   }
#   join: six_degree_movie {
#     view_label: "6th Degree"
#     from: title
#     fields: [title]
#     sql_on: ${degrees_of_kevin_bacon.six_movie_id} = ${six_degree_movie.id} ;;
#   }
}

explore: title_base {
  view_name: title
  label: "Title"
  #sql_always_where: ${title.kind_id} <> 2
  join: cast_info {
    view_label: "Cast Member"
    sql_on: ${title.id} = ${cast_info.movie_id} ;;
    relationship: one_to_many
  }

  join: char_name {
    view_label: "Cast Member"
    sql_on: ${char_name.id} = ${cast_info.person_role_id} ;;
    relationship: one_to_many
  }

  join: name {
    view_label: "Cast Member"
    sql_on: ${cast_info.person_id} = ${name.id} ;;
    relationship: many_to_one
  }

  join: cast_title_facts {
    view_label: "Cast Member"
    sql_on: ${cast_info.person_id} = ${cast_title_facts.person_id} ;;
    relationship: many_to_one
  }

  join: cast_top_genre {
    view_label: "Cast Member"
    sql_on: ${cast_info.person_id} = ${cast_top_genre.person_id} ;;
    relationship: many_to_one
  }

  join: cast_info2 {
    view_label: "Cast Member (also in Title)"
    from: cast_info
    sql_on: ${title.id} = ${cast_info2.movie_id} ;;
    relationship: one_to_many
  }

  join: char_name2 {
    view_label: "Cast Member (also in Title)"
    from: char_name
    sql_on: ${char_name2.id} = ${cast_info2.person_role_id} ;;
    relationship: one_to_many
  }

  join: name2 {
    view_label: "Cast Member (also in Title)"
    from: name
    sql_on: ${cast_info2.person_id} = ${name2.id} ;;
    relationship: many_to_one
  }

  join: movie_companies {
    sql_on: ${title.id} = ${movie_companies.movie_id} ;;
    relationship: one_to_many
  }

  join: company_name {
    view_label: "Production Company"
    sql_on: ${movie_companies.company_id} = ${company_name.id} ;;
    relationship: many_to_one
  }

  join: movie_companies2 {
    from: movie_companies
    sql_on: ${title.id} = ${movie_companies2.movie_id} ;;
    relationship: one_to_many
  }

  join: company_name_2 {
    from: company_name
    view_label: "Production Company (also in Title)"
    sql_on: ${movie_companies2.company_id} = ${company_name_2.id} ;;
    relationship: many_to_one
  }

  join: movie_keyword {
    view_label: "Title Keyword"
    sql_on: ${title.id} = ${movie_keyword.movie_id} ;;
    relationship: one_to_many
  }

  #     - join: movie_has_keyword
  #       view_label: Title Keyword
  #       sql_on: ${title.id} = ${movie_has_keyword.movie_id}
  #       relationship: one_to_many

  join: movie_keyword_2 {
    view_label: "Title Keyword (also in Title)"
    from: movie_keyword
    sql_on: ${title.id} = ${movie_keyword_2.movie_id} ;;
    relationship: one_to_many
  }

  join: movie_genre {
    view_label: "Title Genre"
    sql_on: ${title.id} = ${movie_genre.movie_id} ;;
    relationship: one_to_many
  }

  #     - join: movie_is_genre
  #       view_label: Title Genre
  #       sql_on: ${title.id} = ${movie_is_genre.movie_id}
  #       relationship: one_to_many

  join: movie_genre2 {
    view_label: "Title Genre (also in Title)"
    from: movie_genre
    sql_on: ${title.id} = ${movie_genre2.movie_id} AND ${movie_genre.genre} <> ${movie_genre2.genre} ;;
    relationship: one_to_many
  }

  join: movie_language {
    view_label: "Title Has Language"
    sql_on: ${title.id} = ${movie_language.movie_id} ;;
    relationship: one_to_many
  }

  join: movie_language2 {
    view_label: "Title Has Language (also in Title)"
    from: movie_language
    sql_on: ${title.id} = ${movie_language2.movie_id} ;;
    relationship: one_to_many
  }

  join: movie_color {
    view_label: "Title"
    sql_on: ${title.id} = ${movie_color.movie_id} ;;
    relationship: one_to_many
  }

  join: movie_country_rating {
    view_label: "Title Rating"
    sql_on: ${title.id} = ${movie_country_rating.movie_id} ;;
    relationship: one_to_many
  }

  join: movie_country_rating2 {
    view_label: "Title Rating (also in Title)"
    from: movie_country_rating
    sql_on: ${title.id} = ${movie_country_rating2.movie_id} ;;
    relationship: one_to_many
  }

  join: movie_weekend_revenue {
    sql_on: ${title.id} = ${movie_weekend_revenue.movie_id} ;;
    relationship: one_to_many
  }

  join: movie_release_dates {
    view_label: "Title Release Dates"
    sql_on: ${title.id} = ${movie_release_dates.movie_id} ;;
    relationship: one_to_many
  }

  join: movie_release_facts {
    sql_on: ${title.id} = ${movie_release_facts.movie_id} ;;
    relationship: many_to_one
    view_label: "Title"
  }

  join: movie_budget {
    sql_on: ${title.id} = ${movie_budget.movie_id} ;;
    relationship: many_to_one
    view_label: "Title"
  }

  join: title_location {
    sql_on: ${title.id} = ${title_location.movie_id} ;;
    relationship: one_to_many
    view_label: "Title"
  }

  join: title_extra {
    view_label: "Title"
  }

  join: tv_series {
    view_label: "TV Episode"
    sql_on: ${title.episode_of_id} = ${tv_series.id} ;;
    relationship: many_to_one
  }

  join: movie_revenue {
    sql_on: ${title.id} = ${movie_revenue.movie_id} ;;
    relationship: many_to_one
    view_label: "Title"
  }
}

# When joining in title, here are the joins you might want to use
explore: title_simple {
  extension: required

  join: movie_revenue {
    sql_on: ${title.id} = ${movie_revenue.movie_id} ;;
    relationship: many_to_one
    view_label: "Title"
  }
}

explore: person_info {
  hidden: yes

  join: name {
    sql_on: ${person_info.person_id} = ${name.id} ;;
    relationship: many_to_one
  }
}

explore: movie_weekend_revenue {
  extends: [title_simple]
  hidden: yes

  join: title {
    sql_on: ${movie_weekend_revenue.movie_id} = ${title.id} ;;
    relationship: many_to_one
  }
}

explore: movie_release_dates {
  extends: [title_simple]
  hidden: yes

  join: title {
    sql_on: ${movie_release_dates.movie_id} = ${title.id} ;;
    relationship: many_to_one
  }
}

explore: movie_release_facts {
  extends: [title_simple]
  hidden: yes

  join: title {
    sql_on: ${movie_release_facts.movie_id} = ${title.id} ;;
    relationship: many_to_one
  }
}

explore: movie_info {
  extends: [title_simple]
  hidden: yes

  join: title {
    sql_on: ${movie_info.movie_id} = ${title.id} ;;
    relationship: many_to_one
  }
}

explore: movie_country_rating {
  hidden: yes
}

explore: movie_budget {
  extends: [title_simple]
  hidden: yes

  join: title {
    sql_on: ${movie_budget.movie_id} = ${title.id} ;;
    relationship: many_to_one
  }
}
