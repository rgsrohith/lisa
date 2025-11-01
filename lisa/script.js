function showPopup(id) {
  document.getElementById(id).style.display = "flex";
}

function closePopup(id) {
  document.getElementById(id).style.display = "none";
}

function login(){
  const email = document.getElementById("loginEmail").value;
  const pass = document.getElementById("loginPass").value;

  if(email && pass){
    alert("✅ Login successful for " + email);
    closePopup("login");
    showPopup("role");
  } else {
    alert("⚠️ Enter login details");
  }
}

function signin(){
  const name = document.getElementById("signinName").value;
  const email = document.getElementById("signinEmail").value;
  const pass = document.getElementById("signinPass").value;

  if(name && email && pass){
    localStorage.setItem("user_" + email, JSON.stringify({name, pass}));
    alert("✅ Account created for " + name);
    closePopup("signin");
  } else {
    alert("⚠️ Fill all fields");
  }
}

function submitRole(){
  const roles = document.getElementsByName("role");
  let selected = "";
  for(let r of roles){
    if(r.checked) selected = r.value;
  }

  if(selected){
    alert("✅ Role selected: " + selected);
    closePopup("role");
    if(selected === "User"){
      window.location.href = "user.html";
    } else {
      window.location.href = "doctor.html";
    }
  } else {
    alert("⚠️ Select a role");
  }
}

function bookAppointment(){
  const name = document.getElementById('patientName').value;
  const doctor = document.getElementById('doctorSelect').value;
  const date = document.getElementById('apptDate').value;
  const time = document.getElementById('apptTime').value;

  if(name && doctor && date && time){
    const appointment = { name, doctor, date, time };
    let appointments = JSON.parse(localStorage.getItem("appointments")) || [];
    appointments.push(appointment);
    localStorage.setItem("appointments", JSON.stringify(appointments));

    alert("✅ Appointment booked for " + name);
    closePopup('appointment');
  } else {
    alert("⚠️ Fill all details");
  }
}
