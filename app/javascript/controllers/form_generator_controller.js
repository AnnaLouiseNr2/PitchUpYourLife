import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="form-generator"
export default class extends Controller {
  static targets = ["input", "submitButton", "errorText"]

  connect() {
    console.log('Form generator controller connected')

    // Store reference to controller on the form element
    if (this.element.tagName === 'FORM') {
      this.element.formGeneratorController = this
    }

    // Add a small delay to ensure all elements are ready
    setTimeout(() => {
      this.updateButton()
    }, 50)
  }

  updateButton() {
    const isValid = this.isValid()
    console.log('Form validation check:', isValid)
    console.log('Input targets found:', this.inputTargets.length)

    // Manual check - find all hidden inputs
    const allHiddenInputs = document.querySelectorAll('input[type="hidden"][required]')
    console.log('All hidden inputs found:', allHiddenInputs.length)

    allHiddenInputs.forEach((input, index) => {
      console.log(`Hidden input ${index + 1}:`, input.name, 'value:', input.value, 'has target attr:', input.hasAttribute('data-form-generator-target'))
    })

    this.inputTargets.forEach((input, index) => {
      console.log(`Input target ${index + 1}:`, input.name, 'value:', input.value, 'valid:', input.value.trim() !== "")
    })

    if (isValid) {
      this.submitButtonTarget.disabled = false
      this.submitButtonTarget.classList.remove("disabled")
      console.log('Button enabled')
    } else {
      this.submitButtonTarget.disabled = true
      this.submitButtonTarget.classList.add("disabled")
      console.log('Button disabled')
    }
  }

  isValid() {
    // Check all targets to see if they have a value
    return this.inputTargets.every(input => {
      // Check if the input is a select tag and has a selected option
      if (input.tagName === "SELECT") {
        return input.value.trim() !== ""
      }

      // For hidden inputs, check if they have a value (they're required for form completion)
      if (input.type === "hidden") {
        return input.value.trim() !== ""
      }

      // Check if it's a visible text input for "Other"
      // If the input is hidden, we don't need it to be filled out
      if (input.style.display !== "none") {
        return input.value.trim() !== ""
      }

      // If it's any other type of input, it is considered valid
      return true
    })
  }

  validateForm(event) {
    if (!this.isValid()) {
      event.preventDefault()
      if (this.hasErrorTextTarget) {
        this.errorTextTarget.style.display = "block"
      }
    }
  }
}
