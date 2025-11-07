module Pages.Home_ exposing (page)

import Html exposing (..)
import Html.Attributes exposing (..)
import View exposing (View)


page : View msg
page =
    { title = "Linguistic Dictionary"
    , body = 
        [ div [ class "container" ]
            [ h1 [] [ text "Linguistic Dictionary" ]
            , p [] [ text "A collaborative, auditable dictionary for linguistic description." ]
            , div [ class "quick-actions" ]
                [ h2 [] [ text "Quick Actions" ]
                , ul []
                    [ li [] [ a [ href "/lexemes" ] [ text "Browse Lexemes" ] ]
                    , li [] [ a [ href "/lexemes/new" ] [ text "Create New Lexeme" ] ]
                    , li [] [ a [ href "/search" ] [ text "Advanced Search" ] ]
                    ]
                ]
            , div [ class "stats" ]
                [ h2 [] [ text "Statistics" ]
                , p [] [ text "Coming soon: corpus size, audio files, and more." ]
                ]
            ]
        ]
    }
