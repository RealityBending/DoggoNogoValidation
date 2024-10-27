// Math utilities =================================================================================
function randomInteger(min = 1, max = 10) {
    return Math.round(Math.random() * (max - min) + min)
}

function opacity(min = 0, max = 1) {
    let randomOpacity = Math.random() * (max - min) + min
    return parseFloat(randomOpacity.toFixed(2))
}

// DoggoNogo ==============================================================================

const instructions_DoggoNogo = {
    type: jsPsychSurvey,
    survey_json: function () {
        let text = "<p><b>Welcome to the "
        if (taskorder === "DoggoFirst") {
            text += "first"
        } else {
            text += "last"
        }
        text +=
            " task of the experiment!</b>" +
            " In this game, you will need to be as fast as possible and press the down arrow button whenever a bone appears.</p>"

        text +=
            "<p align='center'><img src='stimuli/bone.png' height=" +
            window.innerHeight / 6 +
            "/></p>"

        text +=
            "<p>You will need to <b>click the link below</b>, which will open the game in a new tab.</p>" +
            "<p>You need to <b>finish the game</b> and then <b>return to this tab</b> to continue the experiment (<i style='color:red;'>do not close this tab while playing the game</i>).</p>"

        text +=
            "<p align='center'><a href='https://sussex-psychology-software-team.github.io/DoggoNogo/?datapipe=AlXXHjfLwVP3&p=" +
            participantID +
            "&s=DoggoNogoValidation&l1n=60' target='_blank'><b style='color:purple; font-size: 150%;'>CLICK HERE TO START THE GAME</b></a></p>"

        text +=
            "<p style='color:green;' align='center'>(Note that the game might take a few seconds to load)</p>"

        return {
            showQuestionNumbers: false,
            title: "Instructions",
            completeText: "I've finished the game and I'm ready to continue the experiment",
            pages: [
                {
                    elements: [
                        {
                            type: "html",
                            name: "instruction",
                            html: text,
                        },
                    ],
                },
            ],
            data: {
                screen: "instructions_DoggoNogo",
            },
        }
    },
    // This function hides the 'Continue' button for a couple of seconds
    on_load: function () {
        function hideButton() {
            const doggoNogoNext = document.querySelector(".jspsych-nav-complete")

            if (doggoNogoNext) {
                doggoNogoNext.style.display = "none"

                setTimeout(function () {
                    doggoNogoNext.style.display = "inline-block"
                }, 1200) // set to ~120000 ms? (2mins)
            } else {
                requestAnimationFrame(hideButton)
            }
        }
        hideButton()
    },
}

// Simple RT ==============================================================================

const instructions_simpleRT = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: function () {
        text = "<h1>Instructions</h1> <p>Welcome to the "
        if (taskorder === "DoggoFirst") {
            text += "last"
        } else {
            text += "first"
        }
        text += " task of the experiment!</p>"

        text +=
            "<p>In this game of speed, a fixation cross (+) will appear in the center of the screen, followed by a red square.</p>" +
            "<p>Whenever the red square appears, press the <b>Down Arrow</b> as fast as you can.</p>" +
            "<p style='float: centre; font-size: 1000%; color: red;'>&#9632</p>" +
            "<p><br>Press the <b>down arrow</b> to begin.</p>"
        return text
    },
    data: {
        screen: "instructions_SimpleRT",
    },
}

const simpleRT_break = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus:
        "<h1>Break</h1>" +
        "<p>You're doing well! Feel free to take a break to relax your eyes.</p>" +
        "<p>Press the <b>down arrow</b> to continue.</p>",
    data: {
        screen: "SimpleRT_break",
    },
}

// Fixation trials - repeats following premature key presses don't have to be the same duration
const _simpleRT_fixationcross = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: '<div style="font-size:60px;">+</div>',
    choices: ["ArrowDown"],
    trial_duration: function () {
        return randomInteger(500, 2000)
    },
    save_trial_parameters: {
        trial_duration: true,
    },
    data: {
        screen: "SimpleRT_fixation",
    },
    response_ends_trial: true,
}

// The fixation trials are put into a timeline that loops if an early response is detected
const simpleRT_fixationcross = {
    timeline: [_simpleRT_fixationcross],
    loop_function: function (data) {
        if (jsPsych.pluginAPI.compareKeys(data.values()[0].response, null)) {
            return false
        } else {
            return true
        }
    },
}

// RT trials
const simpleRT_trial = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: function () {
        let windowWidth = (window.innerWidth / 2) * 0.75
        let windowHeight = (window.innerHeight / 2) * 0.75
        return (
            `<div style="position: relative; left: ${randomInteger(
                -windowWidth,
                windowWidth
            )}px; top: ${randomInteger(-windowHeight, windowHeight)}px;` +
            `color: red; opacity: ${opacity(0.2, 1)}; font-size: ${
                randomInteger(5, 30) * 10
            }px">&#9632</div>`
        )
    },
    choices: ["ArrowDown"],
    trial_duration: 600,
    data: {
        screen: "SimpleRT_stimulus",
    },
}

// Linking fixation and RT trials
const simpleRT_block = {
    timeline: [simpleRT_fixationcross, simpleRT_trial],
    randomize_order: true,
    repetitions: 2, // number of trials
}

// Post-task assessment ==============================================================================

// Questions
const task_assessment = {
    type: jsPsychSurvey,
    survey_json: {
        title: "Feedback",
        completeText: "Continue",
        pageNextText: "Next",
        pagePrevText: "Previous",
        goNextPageAutomatic: false,
        showQuestionNumbers: false,
        pages: [
            {
                description: "These questions are pertaining to the task you just completed.",
                elements: [
                    {
                        title: "How much did you enjoy the previous task?",
                        name: "TaskFeedback_Enjoyment",
                        type: "rating",
                        minRateDescription: "Boring",
                        maxRateDescription: "Fun",
                        rateType: "stars",
                        rateMin: 0,
                        rateMax: 7,
                        isRequired: true,
                    },
                    {
                        type: "text",
                        title: "Without checking the time, how long do you think you spent doing the previous task?",
                        name: "TaskFeedback_Duration",
                        isRequired: true,
                        inputType: "number",
                        min: 0,
                        max: 90,
                        placeholder: "Time in minutes (e.g., 6.5)",
                    },
                    {
                        title: "How would you feel if you had to do the same task again one more time?",
                        name: "TaskFeedback_Repeat",
                        type: "rating",
                        rateType: "smileys",
                        rateMin: -4,
                        rateMax: 4,
                        minRateDescription: "Very annoyed",
                        maxRateDescription: "Very happy",
                        isRequired: true,
                    },
                ],
            },
        ],
    },
    data: {
        screen: "task_assessment",
    },
}

// Task sequence ======================================================================================

var DoggoNogo = {
    timeline: [instructions_DoggoNogo, task_assessment],
}

var SimpleRT = {
    timeline: [
        instructions_simpleRT,
        simpleRT_block,
        simpleRT_break,
        simpleRT_block,
        simpleRT_break,
        simpleRT_block,
        task_assessment,
    ],
}
