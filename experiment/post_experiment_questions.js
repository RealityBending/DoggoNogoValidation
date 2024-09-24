// Questions
var post_qs = {
    type: jsPsychSurvey,
    survey_json: {
        title: "Post experiment questions",
        completeText: "Continue",
        pageNextText: "Next",
        pagePrevText: "Previous",
        goNextPageAutomatic: false,
        showQuestionNumbers: false,
        showProgressBar: "aboveHeader",
        pages: [
            {
                elements: [
                    {
                        type: "text",
                        title: "Without checking, how long do you feel you spent on this task? Please answer in minutes.",
                        name: "duration_estimate",
                        isRequired: true,
                        inputType: "number",
                        min: 0,
                        max: 100,
                        placeholder: "Time in minutes (e.g., 5)",
                    },
                ],
            },
            {
                elements: [
                    {
                        title: "How would you feel if you had to do the task again?",
                        name: "repeat_desirability",
                        type: "rating",
                        minRateDescription: "Very annoyed",
                        maxRateDescription: "Very happy",
                        isRequired: true
                    },
                ],
            },
        ],
    },
    data: {
        screen: "post_qs",
    },
}