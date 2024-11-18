// Consent
const ConsentForm = {
    type: jsPsychSurvey,
    survey_json: function () {
        // Get URL variables
        let urlvars = jsPsych.data.urlVariables()

        // Logo and title
        let text =
            "<img src='https://blogs.brighton.ac.uk/sussexwrites/files/2019/06/University-of-Sussex-logo-transparent.png' width='150px' align='right'/><br><br><br><br><br>" +
            "<h1>Informed Consent</h1>"

        if (urlvars["exp"] == "surveyswap") {
            text +=
                "<p style='color:green;' align='left'><b>Note: You will receive a <i style='color:purple;'>SurveySwap.io</i> completion code at the end of the experiment.</b></p>"
        }

        if (jsPsych.data.urlVariables()["exp"] == "SONA") {
            text +=
                "<p style='color:green;' align='left'><b>Note: You will receive a <i style='color:purple;'>SONA</i> completion link at the end of the experiment.</b></p>"
        }

        // Main Text
        text +=
            // Overview
            "<p align='left'><b>Invitation to Take Part</b><br>" +
            `Thank you for considering to take part in this study conducted by Benjamin Tribe and Dr Dominique Makowski from the University of Sussex (see contact information below).</p>` +
            // Description
            "<p align='left'><b>Why have I been invited and what will I do?</b><br>" +
            "The goal is to study experience and performance on two different presentations of a simple reaction time task. " +
            `The whole experiment will take you <b style='color:#FF5722;'>~30 minutes</b> to complete. Please make you sure that you are <b>attentive and in a quiet environment</b>, and that you have time to complete it in one go.</p>` +
            // Results and personal information
            "<p align='left'><b>What will happen to the results and my personal information?</b><br>" +
            "The results of this research may be written into a scientific publication. Your anonymity will be ensured in the way described in the consent information below. <b>Please read this information carefully</b> and then, if you wish to take part, please acknowledge that you have fully understood this sheet, and that you consent to take part in the study as it is described here.</p>" +
            "<p align='left'><b>Consent</b><br></p>" +
            // Bullet points
            "<li align='left'>I understand that by signing below I am agreeing to take part in the University of Sussex research described here, and that I have read and understood this information sheet</li>" +
            "<li align='left'>I understand that my participation is entirely voluntary, that I can choose not to participate in part or all of the study, and that I can withdraw at any stage without having to give a reason and without being penalized in any way (e.g., if I am a student, my decision whether or not to take part will not affect my grades).</li>" +
            "<li align='left'>I understand that since the study is anonymous, it will be impossible to withdraw my data once I have completed it.</li>" +
            "<li align='left'>I understand that my personal data will be used for the purposes of this research study and will be handled in accordance with Data Protection legislation. I understand that the University's Privacy Notice provides further information on how the University uses personal data in its research.</li>" +
            "<li align='left'>I understand that my collected data will be stored in a de-identified way. De-identified data may be made publicly available through secured scientific online data repositories.</li>"

        // Incentive
        if (["surveyswap", "prolific"].includes(urlvars["exp"])) {
            text +=
                "<li align='left'>Please note that <b style='color:#FF5722;'>various checks will be performed to ensure the validity of the data</b>. We reserve the right to withhold credit awards or reimbursement should we detect non-valid responses (e.g., random patterns of answers, instructions not read, ...).</li>"
        }

        // End
        text +=
            "<li align='left'>By participating, you agree to follow the instructions and provide honest answers. If you do not wish to participate or if you don't have the time, simply close your browser.</li></p>" +
            `<p align='left'><br><sub><sup>For further information about this research, or if you have any concerns, please contact Benjamin Tribe (<i style='color:DodgerBlue;'>bmt26@sussex.ac.uk</i>) or Dr Dominique Makowski (<i style='color:DodgerBlue;'>D.Makowski@sussex.ac.uk</i>). This research has been approved (ER/BMT26/5) by the ethics board of the School of Psychology. The University of Sussex has insurance in place to cover its legal liabilities in respect of this study.</sup></sub></p>`

        // Return Survey
        return {
            showQuestionNumbers: false,
            completeText: "I read, understood, and I consent",
            pages: [
                {
                    elements: [
                        {
                            type: "html",
                            name: "ConsentForm",
                            html: text,
                        },
                    ],
                },
            ],
        }
    },
    data: {
        screen: "demographic_consentform",
    },
}

// Retrieve and save browser info ========================================================
var demographics_browser_info = {
    type: jsPsychBrowserCheck,
    data: {
        screen: "browser_info",
        date: new Date().toLocaleDateString("en-GB"),
        time: new Date().toLocaleTimeString("en-GB"),
    },
    on_finish: function (data) {
        data["participantID"] = participantID
        data["condition"] = taskorder

        // Rename
        dat = jsPsych.data.get().filter({ screen: "browser_info" }).values()[0]
        data["screen_height"] = dat["height"]
        data["screen_width"] = dat["width"]

        // Add URL variables - ?sona_id=x&exp=1
        let urlvars = jsPsych.data.urlVariables()
        data["researcher"] = urlvars["exp"]
        data["sona_id"] = urlvars["sona_id"]
        data["prolific_id"] = urlvars["PROLIFIC_PID"] // Prolific
        data["study_id"] = urlvars["STUDY_ID"] // Prolific
        data["session_id"] = urlvars["SESSION_ID"] // Prolific
    },
}

// Demographics
const demographic_questions = {
    type: jsPsychSurvey,
    survey_json: {
        title: "About yourself",
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
                        title: "What is your gender?",
                        name: "Gender",
                        type: "radiogroup",
                        choices: ["Male", "Female"],
                        showOtherItem: true,
                        otherText: "Other",
                        isRequired: true,
                        colCount: 0,
                    },
                    {
                        visibleIf: "{Gender} == 'Other'",
                        title: "You selected 'Other' as your gender. Specify if you wish.",
                        name: "GenderOther",
                        type: "text",
                        isRequired: false,
                        inputType: "text",
                        placeholder: "Gender",
                    },
                    {
                        type: "text",
                        title: "Please enter your age (in years)",
                        name: "Age",
                        isRequired: true,
                        inputType: "number",
                        min: 18,
                        max: 100,
                        placeholder: "e.g., 21",
                    },
                    {
                        title: "What is your handedness?",
                        name: "Handedness",
                        type: "radiogroup",
                        choices: [
                            "Left-handed",
                            "Right-handed",
                            "Ambidextrous",
                        ],
                        isRequired: true,
                        colCount: 0,
                    },
                ],
            },
            {
                elements: [
                    {
                        title: "What is your highest completed education level?",
                        name: "Education",
                        type: "radiogroup",
                        choices: [
                            {
                                value: "Doctorate",
                                text: "University (doctorate)",
                            },
                            {
                                value: "Master",
                                text: "University (master)", // "<sub><sup>or equivalent</sup></sub>",
                            },
                            {
                                value: "Bachelor",
                                text: "University (bachelor)", // "<sub><sup>or equivalent</sup></sub>",
                            },
                            {
                                value: "High school",
                                text: "High school",
                            },
                            {
                                value: "Elementary school",
                                text: "Elementary school",
                            },
                        ],
                        showOtherItem: true,
                        otherText: "Other",
                        otherPlaceholder: "Please specify",
                        isRequired: true,
                        colCount: 1,
                    },
                    {
                        visibleIf:
                            "{Education} == 'Doctorate' || {Education} == 'Master' || {Education} == 'Bachelor'",
                        title: "What is your discipline?",
                        name: "Discipline",
                        type: "radiogroup",
                        choices: [
                            "Arts and Humanities",
                            "Literature, Languages",
                            "History, Archaeology",
                            "Sociology, Anthropology",
                            "Political Science, Law",
                            "Business, Economics",
                            "Psychology, Neuroscience",
                            "Medicine",
                            "Biology, Chemistry, Physics",
                            "Mathematics, Physics",
                            "Engineering, Computer Science",
                        ],
                        showOtherItem: true,
                        otherText: "Other",
                        otherPlaceholder: "Please specify",
                    },
                    {
                        visibleIf:
                            "{Education} == 'High school' || {Education} == 'Master' || {Education} == 'Bachelor'",
                        title: "Are you currrently a student?",
                        name: "Student",
                        type: "boolean",
                        swapOrder: true,
                        isRequired: true,
                    },
                ],
            },
            {
                elements: [
                    {
                        title: "How would you describe your ethnicity?",
                        name: "Ethnicity",
                        type: "radiogroup",
                        choices: [
                            "White",
                            "Black",
                            "Hispanic/Latino",
                            "Middle Eastern/North African",
                            "South Asian",
                            "East Asian",
                            "Southeast Asian",
                            "Mixed",
                            "Prefer not to say",
                        ],
                        showOtherItem: true,
                        otherText: "Other",
                        otherPlaceholder: "Please specify",
                        isRequired: false,
                        colCount: 1,
                    },
                    {
                        title: "In which country are you currently living?",
                        name: "Country",
                        type: "dropdown",
                        choicesByUrl: {
                            url: "https://surveyjs.io/api/CountriesExample",
                        },
                        placeholder: "e.g., France",
                        isRequired: false,
                    },
                ],
            },
        ],
    },
    data: {
        screen: "demographic_questions",
    },
}

// Thank you ========================================================================

var experiment_feedback = {
    type: jsPsychSurvey,
    survey_json: {
        title: "Feedback",
        description:
            "It is the end of the experiment! Don't hesitate to leave us a feedback.",
        completeText: "Complete the experiment",
        showQuestionNumbers: false,
        pages: [
            {
                elements: [
                    {
                        type: "rating",
                        name: "Feedback_Enjoyment",
                        title: "Did you enjoy doing this experiment?",
                        isRequired: false,
                        rateMin: 0,
                        rateMax: 4,
                        rateType: "stars",
                    },
                    {
                        type: "comment",
                        name: "Feedback_Text",
                        title: "Anything else you would like to share with us?",
                        description:
                            "Please note that these comments might be shared publicly as part of the results of this study - avoid sharing personal information.",
                        isRequired: false,
                    },
                ],
            },
        ],
    },
    data: {
        screen: "experiment_feedback",
    },
}

const experiment_debriefing = {
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

const experiment_endscreen = {
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
        if (jsPsych.data.urlVariables()["exp"] == "SONA") {
            text +=
                "<p style='color:red;'><b>Click " +
                "<a href='https://sussexpsychology.sona-systems.com/webstudy_credit.aspx?experiment_id=1906&credit_token=ec164f49e113489ea9a181962295d8e8&survey_code=" +
                jsPsych.data.urlVariables()["sona_id"] +
                "'>here<a/>" +
                " to redeem your SONA credits</b><br></p>"
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
