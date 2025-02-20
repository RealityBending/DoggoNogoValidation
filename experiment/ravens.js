// Adapted from: https://github.com/nivlab/jspsych-demos/tree/main/tasks/rpm
// Raven's progressive matrices (RPM) JsPsych implementation

// The abbreviated 9-item Raven's standard progressive matrices forms A and B.
// -Bilker, W. B., Hansen, J. A., Brensinger, C. M., Richard, J., Gur, R. E., & Gur, R. C. (2012). Development of abbreviated nine-item forms of the Raven's standard progressive matrices test. Assessment, 19(3), 354-369.

// Instructions =================================================================
const ravens_instructions = {
    type: jsPsychSurvey,
    survey_json: {
        showQuestionNumbers: false,
        completeText: "Let's start",
        pages: [
            {
                elements: [
                    {
                        type: "html",
                        name: "ravens_instructions",
                        html:
                            "<div style='display: flex;'>" +
                            "<div style='width: 60%; margin-right: 20px;'>" +
                            "<h1>Puzzle Task</h1>" +
                            "<p>In the following puzzle game task, you will be shown a series of puzzles. For each puzzle, your goal is to identify the missing piece from the options appearing below the puzzle.</p>" +
                            "<p>There are 9 puzzles in total. You will have <b>30 seconds</b> for each puzzle. Try to be as accurate as you can be.</p>" +
                            "<p>If you cannot solve the puzzle before time runs out, then you should guess.</p>" +
                            "</div>" +
                            "<div style='width: 40%;'>" +
                            "<img src='https://realitybending.github.io/JSmisc/tasks/RPM/ravens_example.png' alt='Example' style='width: 70%;'>" +
                            "</div>" +
                            "</div>",
                    },
                ],
            },
        ],
    },
}

// Stimuli =====================================================================
function ravens_makestimuli(path = "https://realitybending.github.io/JSmisc/tasks/RPM/ravens_stimuli/") {
    var stims = [
        { item: "a11", n_choices: 6, correct: 4 },
        { item: "a24", n_choices: 6, correct: 4 },
        { item: "a28", n_choices: 8, correct: 7 },
        { item: "a36", n_choices: 8, correct: 1 },
        { item: "a43", n_choices: 8, correct: 4 },
        { item: "a48", n_choices: 8, correct: 5 },
        { item: "a49", n_choices: 8, correct: 6 },
        { item: "a53", n_choices: 8, correct: 0 },
        { item: "a55", n_choices: 8, correct: 1 },
        // { item: "b10", n_choices: 6, correct: 2 },
        // { item: "b16", n_choices: 6, correct: 1 },
        // { item: "b21", n_choices: 6, correct: 3 },
        // { item: "b30", n_choices: 8, correct: 3 },
        // { item: "b34", n_choices: 8, correct: 5 },
        // { item: "b44", n_choices: 8, correct: 3 },
        // { item: "b50", n_choices: 8, correct: 5 },
        // { item: "b52", n_choices: 8, correct: 1 },
        // { item: "b57", n_choices: 8, correct: 0 },
    ]
    for (let i = 0; i < stims.length; i++) {
        stims[i].path = `<img src=${path + stims[i].item}.png></img>`
        stims[i].n_cols = stims[i].n_choices / 2
        stims[i].choices = []
        for (let j = 1; j <= stims[i].n_choices; j++) {
            stims[i].choices.push(`<img src=${path + stims[i].item}_${j}.png></img>`)
        }
    }
    return stims
}

const ravens_stims = ravens_makestimuli("https://realitybending.github.io/JSmisc/tasks/RPM/ravens_stimuli/")

const ravens_preload = {
    type: jsPsychPreload,
    images: ravens_stims.flatMap(({ path, choices }) => [path, ...choices]).map((str) => str.match(/(?<=src=)["']?([^"'>]+\.png)/)[1]),
    message: "Loading images. This may take a moment depending on your internet connection.",
    error_message:
        "<p>The experiment failed to load. Please try restarting your browser.</p><p>If this error persists after 2-3 tries, please contact the experimenter.</p>",
    continue_after_error: false,
    show_progress_bar: true,
    max_load_time: 30000,
}

// Trials ======================================================================
function ravens_maketrial() {
    return {
        type: jsPsychHtmlButtonResponse,
        prompt: "<p>Which option completes the pattern?<br><b><span id='clock'> </span></b></p>",
        stimulus: jsPsych.timelineVariable("path"),
        choices: jsPsych.timelineVariable("choices"),
        grid_columns: jsPsych.timelineVariable("n_cols"),
        trial_duration: 30000,
        button_html: (choice) => `<button class="jspsych-btn" style="border: none">${choice}</button>`,
        data: {
            screen: "ravens_trial",
            correct: jsPsych.timelineVariable("correct"),
            item: jsPsych.timelineVariable("item"),
        },
        // Countdown timer (https://github.com/jspsych/jsPsych/discussions/1690)
        on_load: function () {
            var duration = 30000 // in milliseconds
            var t0 = performance.now()
            var interval = setInterval(function () {
                var time_left = (duration - (performance.now() - t0)) / 1000
                if (time_left <= 6) {
                    document.querySelector("#clock").innerHTML = Math.floor(time_left).toString()
                }
                if (time_left <= 0) {
                    // reset clock to empty string
                    document.querySelector("#clock").innerHTML = " "
                    clearInterval(interval)
                }
            }, 250)
        },
        on_finish: function (data) {
            data.error = data.response != data.correct
        },
    }
}

function ravens_procedure() {
    return {
        timeline: [ravens_maketrial()],
        timeline_variables: ravens_stims,
        randomize_order: false,
    }
}
