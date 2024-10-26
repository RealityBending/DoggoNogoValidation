// Math utilities =================================================================================
function randomInteger(min = 1, max = 10) {
    return Math.round(Math.random() * (max - min) + min)
}

function opacity(min=0, max=1){
    let randomOpacity = Math.random() * (max - min) + min;
    return parseFloat(randomOpacity.toFixed(2))
}

// Instructions ===================================================================================
const simpleRT_instructions = {
    type: jsPsychHtmlKeyboardResponse,
    stimulus: `
    <p>In this experiment, a fixation cross (+) will appear in the center
    of the screen, followed by a red square.</p>
    <p>Whenever the red square appears,
    press the <strong>Down Arrow</strong> as fast as you can.</p>
    <div style='float: centre; font-size: 200px; color: red;'>&#9632
    </div><br><br>
    <p>Press the <b>down arrow</b> to begin.</p>
    `,
    post_trial_gap: 2000,
}

const experiment_feedback = {
    type: jsPsychSurvey,
    survey_json: {
        title: "Feedback",
        completeText: "Continue",
        pageNextText: "Next",
        pagePrevText: "Previous",
        goNextPageAutomatic: true,
        showQuestionNumbers: false,
        pages: [
            {
                elements: [
                    {
                        title: "It is the end of the experiment! Don't hesitate to leave us feedback.",
                        description: "Please note that these comments might be shared publically alongside the results of this study.",
                        name: "comments",
                        type: "comment",
                        autoGrow: true,
                        allowResize: true,
                        isRequired: false,
                    },
                    {
                        title: "After clicking 'Continue', your data will be saved on our secure servers, after what we will provide you with more information about the study.",
                        name: "end_instruction",
                        type: "html",
                        html: "After clicking 'Continue', your data will be saved on our secure servers. We will then provide you with more information about the study.",
                    },
                ],
            },
        ],
    },
    data: {
        screen: "feedback",
    },
}

const demographics_debriefing = {
    type: jsPsychSurvey,
    survey_json: {
        showQuestionNumbers: false,
        completeText: "Continue",
        pages: [
            {
                elements: [
                    {
                        type: "html",
                        name: "debrief",
                        html:
                            "<h2>Debriefing</h2>" +
                            "<p align='left'>The purpose of this study was to investigate the validity and effect of a gamified simple reaction time task on engagement and performance. " +
                            "Specifically, we want to see whether individuals performed similarly across the two versions of the task, " +
                            "and to test the hypothesis that gamification would lead to reduced variability (i.e., more consistency) in individuals reaction times, and greater enjoyment ratings than the non-gamified version.</p>" +
                            "<p align='left'><b>Thank you!</b> Your participation in this study will be kept completely confidential. If you have any questions or concerns about the project, please contact Benjamin Tribe (<i style='color:DodgerBlue;'>bmt26@sussex.ac.uk</i>) or Dr Dominique Makowski (<i style='color:DodgerBlue;'>D.Makowski@sussex.ac.uk</i>)</p>" +
                            "<p>To complete your participation in this study, click on 'Continue' and <b>wait until your responses have been successfully saved</b> before closing the tab.</p> ",
                    },
                ],
            },
        ],
    },
    data: {
        screen: "debriefing",
    },
}

const endscreen = {
    type: jsPsychSurvey,
    survey_json: function () {
        let text =
            "<h1>Thank you for participating</h1>" +
            "<p>It means a lot to us. Don't hesitate to share the study by sending this link <i>(but please don't reveal the details of the experiment)</i>:</p>" +
            "<p><a href='" +
            "https://realitybending.github.io/DoggoNogoValidation/experiment/index.html" + // Modify this link to the actual experiment
            "'>" +
            "https://realitybending.github.io/DoggoNogoValidation/experiment/index.html" + // Modify this link to the actual experiment
            "<a/></p>"

        // Deal with Prolific/SurveyCircle/SurveySwap/SONA
        if (jsPsych.data.urlVariables()["exp"] == "surveycircle") {
            text +=
                "<p style='color:red;'><b>Click " +
                "<a href='https://www.surveycircle.com/HZPT-7R9E-GVNM-PQ45/'>here<a/>" +
                " to redeem your SurveyCircle participation</b><br>(in case the link doesn't work, the code is: HZPT-7R9E-GVNM-PQ45)</p>" // code??
        }
        if (jsPsych.data.urlVariables()["exp"] == "surveyswap") {
            text +=
                "<p style='color:red;'><b>Click " +
                "<a href='https://surveyswap.io/sr/E9XP-DWMS-BHA3'>here<a/>" +
                " to redeem your SurveySwap participation</b><br>(in case the link doesn't work, the code is: E9XP-DWMS-BHA3)</p>" // code??
        }
        return {
            showQuestionNumbers: false,
            completeText: "End experiment",
            pages: [
                {
                    elements: [
                        {
                            type: "html",
                            name: "endscreen",
                            html: text,
                        },
                    ],
                },
            ],
        }
    },
    data: {
        screen: "end",
    },
}

// Post-task assessment ==============================================================================

// Questions
const simpleRT_assessment = {
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
        screen: "task_postquestionnaire",
    },
}

// Experiment =====================================================================================
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
        screen: "fixation",
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
    stimulus: function(){
        let windowWidth = (window.innerWidth/2)*0.75;
        let windowHeight = (window.innerHeight/2)*0.75;
        return `<div style="position: relative; left: ${randomInteger(-windowWidth, windowWidth)}px; top: ${randomInteger(-windowHeight,windowHeight)}px;`+
        `color: red; opacity: ${opacity(0.2,1)}; font-size: ${randomInteger(5,30)*10}px">&#9632</div>`
},
    choices: ["ArrowDown"],
    trial_duration: 600,
    data: {
        screen: "response",
    }
}

// Linking fixation and RT trials
const simpleRT_task = {
    timeline: [simpleRT_fixationcross, simpleRT_trial],
    randomize_order: true,
    repetitions: 3, // number of trials
}