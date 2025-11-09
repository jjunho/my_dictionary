module Pages.Lexemes exposing (Model, Msg, page)

import Html exposing (..)
import Html.Attributes exposing (..)
import View exposing (View)
import Page exposing (Page)


type alias Model =
    { lexemes : List Lexeme
    }


type alias Lexeme =
    { id : String
    , lemma : String
    , partOfSpeech : Maybe String
    , language : String
    }


type Msg
    = NoOp


page : Page Model Msg
page =
    Page.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Msg )
init =
    ( { lexemes = [] }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> View Msg
view model =
    { title = "Lexemes"
    , body =
        [ div [ class "container" ]
            [ h1 [] [ text "Lexemes" ]
            , div [ class "actions" ]
                [ a [ href "/lexemes/new", class "button" ] [ text "Create New Lexeme" ]
                ]
            , div [ class "filters" ]
                [ p [] [ text "Filters coming soon..." ]
                ]
            , div [ class "lexeme-list" ]
                [ if List.isEmpty model.lexemes then
                    p [] [ text "No lexemes found. Create your first lexeme!" ]
                  else
                    table []
                        [ thead []
                            [ tr []
                                [ th [] [ text "Lemma" ]
                                , th [] [ text "Language" ]
                                , th [] [ text "Part of Speech" ]
                                , th [] [ text "Actions" ]
                                ]
                            ]
                        , tbody []
                            (List.map viewLexemeRow model.lexemes)
                        ]
                ]
            ]
        ]
    }


viewLexemeRow : Lexeme -> Html Msg
viewLexemeRow lexeme =
    tr []
        [ td [] [ text lexeme.lemma ]
        , td [] [ text lexeme.language ]
        , td [] [ text (Maybe.withDefault "-" lexeme.partOfSpeech) ]
        , td []
            [ a [ href ("/lexemes/" ++ lexeme.id) ] [ text "View" ]
            , text " | "
            , a [ href ("/lexemes/" ++ lexeme.id ++ "/edit") ] [ text "Edit" ]
            ]
        ]
