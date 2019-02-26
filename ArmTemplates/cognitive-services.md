# Cognitive Services account

Creates a Cognitive Services account.
Cognitive Services is a general wrapper around Azure AI services.

## Paramaters

cognitiveServiceName: (required) string

Name of Cognitive Services account.
Will be created in the same resource group as the script is run and in the default location for resource group.

cognitiveServiceType: (required) string

The type of AI service required.
Must be one of Bing.Autosuggest.v7, Bing.CustomSearch, Bing.EntitySearch, Bing.Search.v7, Bing.SpellCheck.v7, CognitiveServices, ComputerVision, ContentModerator, CustomVision.Prediction, CustomVision.Training, Face, Internal.AllInOne, LUIS, QnAMaker, SpeakerRecognition, SpeechServices, TextAnalytics or TextTranslation.

Some Cognitive Services account types are non-regional and will deploy with a global location,
see https://azure.microsoft.com/en-us/global-infrastructure/services/?products=cognitive-services&regions=all for details.

cognitiveServiceSku: (optional) string

Specifies the Cognitive Services account SKU to use.
Must be either F0 or S1 to S4.
