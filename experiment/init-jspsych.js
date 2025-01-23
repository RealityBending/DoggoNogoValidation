// Initialize experiment =================================================
var jsPsych = initJsPsych({
  // show_progress_bar: true,
  // message_progress_bar: "Progress",
  on_finish: function () {
      // jsPsych.data.displayData("json") // Display data in browser
      if (jsPsych.data.urlVariables()["exp"] == "SONA") {
          window.location =
              "https://sussexpsychology.sona-systems.com/webstudy_credit.aspx?experiment_id=1906&credit_token=ec164f49e113489ea9a181962295d8e8&survey_code=" +
              jsPsych.data.urlVariables()["sona_id"]
      } else {
          window.location = "https://realitybending.github.io/" // Redirect to lab website
      }
  },
})