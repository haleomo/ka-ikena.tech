const navToggle = document.querySelector(".nav-toggle");
const navLinks = document.querySelector(".nav-links");

if (navToggle && navLinks) {
  navToggle.addEventListener("click", () => {
    const isOpen = navLinks.classList.toggle("open");
    navToggle.setAttribute("aria-expanded", String(isOpen));
  });
}

const contactForm = document.querySelector(".contact-form");
if (contactForm) {
  contactForm.addEventListener("submit", async (event) => {
    event.preventDefault();
    const submitButton = contactForm.querySelector("button[type='submit']");
    
    let endpoint = getApiUrl();
    // if (window.location.hostname === "localhost" && window.location.port === "8888") {
    //   if (endpoint.startsWith("/")) {
    //     endpoint = "http://localhost:8080/api/contact";
    //   }
    // }
    const formData = new FormData(contactForm);
    const payload = {
      name: formData.get("name"),
      email: formData.get("email"),
      message: formData.get("message"),
    };

    if (submitButton) {
      submitButton.disabled = true;
      submitButton.textContent = "Sending...";
    }

    try {
      console.log("Sending contact form data to:", endpoint);
      const response = await fetch(endpoint, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(payload),
      });

      if (!response.ok) {
        let errorMessage = response.statusText || "Request failed";
        try {
          const errorData = await response.json();
          errorMessage = errorData.details || errorData.error || errorMessage;
        } catch (_) {
          const errorText = await response.text();
          if (errorText) {
            errorMessage = errorText;
          }
        }
        throw new Error(errorMessage);
      }

      contactForm.reset();
      alert("Thanks for reaching out! We'll be in touch shortly.");
    } catch (error) {
      alert("Sorry, there was a problem sending your message." + error.message);
      console.error("Error sending contact form:", error);
    } finally {
      if (submitButton) {
        submitButton.disabled = false;
        submitButton.textContent = "Send inquiry";
      }
    }
  });
}

/**
 * Get the API URL based on the ENVIRONMENT variable
 * Checks window.ENVIRONMENT first, then falls back to location hostname
 */
function getApiUrl() {
    // Check if ENVIRONMENT variable is set on window object
    const environment = window.ENVIRONMENT || localStorage.getItem('ENVIRONMENT') || 'dev';
    
    if (environment === 'test') {
        // Use the actual server IP for production (update this to match your server)
        return 'http://192.168.102.204:8080/api/contact';
    }

    if (environment === 'prod') {
        // Use the HTTPS domain for production
        // Requires proper SSL setup on the server
        // See the Deployment documentation for details
        return 'https://ka-ikena.tech/api/contact';
    }

    // Default to dev (localhost for local development)
    return "http://localhost:8080/api/contact";
}