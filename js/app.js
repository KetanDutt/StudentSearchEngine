/**
 * FindinG - Modern App JS v2.0
 * Production-ready client-side logic
 */

(function() {
  'use strict';

  // Config
  const CONFIG = {
    API_BASE: '',
    DEBOUNCE_DELAY: 300,
    PASSWORD_MIN_LENGTH: 8
  };

  // Utilities
  const Utils = {
    debounce: (func, wait) => {
      let timeout;
      return function executedFunction(...args) {
        const later = () => {
          clearTimeout(timeout);
          func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
      };
    },

    showAlert: (message, type = 'danger', containerId = 'alertContainer') => {
      const container = document.getElementById(containerId) || document.body;
      const alert = document.createElement('div');
      alert.className = `alert alert-${type} alert-dismissible fade show`;
      alert.innerHTML = `
        ${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
      `;
      container.prepend(alert);
      setTimeout(() => alert.remove(), 5000);
    },

    validateEmail: (email) => {
      return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
    },

    validatePassword: (pwd) => {
      if (pwd.length < CONFIG.PASSWORD_MIN_LENGTH) return `Password must be at least ${CONFIG.PASSWORD_MIN_LENGTH} characters`;
      if (!/[A-Z]/.test(pwd)) return 'Password must contain uppercase letter';
      if (!/[a-z]/.test(pwd)) return 'Password must contain lowercase letter';
      if (!/[0-9]/.test(pwd)) return 'Password must contain number';
      return null;
    },

    sanitize: (str) => {
      const div = document.createElement('div');
      div.textContent = str;
      return div.innerHTML;
    }
  };

  // Form Validations
  const Validators = {
    login: (form) => {
      const usr = form.querySelector('[name="usr"]')?.value.trim();
      const pwd = form.querySelector('[name="pwd"]')?.value;
      
      if (!usr) {
        Utils.showAlert('Please provide your User Name!');
        return false;
      }
      if (!pwd) {
        Utils.showAlert('Please provide your Password!');
        return false;
      }
      if (usr.length < 3) {
        Utils.showAlert('Username must be at least 3 characters');
        return false;
      }
      return true;
    },

    register: (form) => {
      const userid = form.querySelector('[name="userid"]')?.value.trim();
      const pwd = form.querySelector('[name="pwd"]')?.value;
      const fname = form.querySelector('[name="fname"]')?.value.trim();
      const lname = form.querySelector('[name="lname"]')?.value.trim();
      const email = form.querySelector('[name="email"]')?.value.trim();
      const occ = form.querySelector('[name="occ"]')?.value;

      if (!userid || userid.length < 3) {
        Utils.showAlert('Username must be at least 3 characters (alphanumeric + underscore)');
        return false;
      }
      if (!/^[a-zA-Z0-9_]+$/.test(userid)) {
        Utils.showAlert('Username can only contain letters, numbers and underscore');
        return false;
      }
      const pwdError = Utils.validatePassword(pwd);
      if (pwdError) {
        Utils.showAlert(pwdError);
        return false;
      }
      if (!fname) {
        Utils.showAlert('First name is required');
        return false;
      }
      if (!lname) {
        Utils.showAlert('Last name is required');
        return false;
      }
      if (!Utils.validateEmail(email)) {
        Utils.showAlert('Please provide a valid email address');
        return false;
      }
      if (!occ) {
        Utils.showAlert('Please select occupation');
        return false;
      }
      return true;
    },

    student: (form) => {
      const required = ['user', 'age', 'mnum', 'fname', 'cid', 'brch', 'sem'];
      for (let field of required) {
        const el = form.querySelector(`[name="${field}"]`);
        if (!el || !el.value.trim()) {
          Utils.showAlert(`${field} is required`);
          el?.focus();
          return false;
        }
      }
      const age = parseInt(form.querySelector('[name="age"]')?.value);
      if (isNaN(age) || age < 16 || age > 60) {
        Utils.showAlert('Please enter valid age (16-60)');
        return false;
      }
      const mnum = form.querySelector('[name="mnum"]')?.value;
      if (!/^[0-9]{10}$/.test(mnum)) {
        Utils.showAlert('Mobile number must be 10 digits');
        return false;
      }
      return true;
    },

    company: (form) => {
      const required = ['user', 'cid', 'yr', 'emp', 'hsal', 'addr'];
      for (let field of required) {
        const el = form.querySelector(`[name="${field}"]`);
        if (!el || !el.value.trim()) {
          Utils.showAlert(`${field} is required`);
          return false;
        }
      }
      const yr = parseInt(form.querySelector('[name="yr"]')?.value);
      if (isNaN(yr) || yr < 1800 || yr > new Date().getFullYear()) {
        Utils.showAlert('Please enter valid establishment year');
        return false;
      }
      return true;
    }
  };

  // Search Enhancements
  const Search = {
    init: () => {
      const searchInput = document.querySelector('input[name="search"]');
      if (!searchInput) return;

      // Add search icon
      const wrapper = searchInput.parentElement;
      if (wrapper && !wrapper.querySelector('.search-icon')) {
        wrapper.classList.add('search-box', 'position-relative');
        const icon = document.createElement('span');
        icon.className = 'search-icon';
        icon.innerHTML = '🔍';
        wrapper.prepend(icon);
        searchInput.style.paddingLeft = '3rem';
      }

      // Live search debounce (optional enhancement)
      const debounced = Utils.debounce((value) => {
        if (value.length >= 2) {
          console.log('Searching for:', value);
          // Could implement AJAX suggestions here
        }
      }, CONFIG.DEBOUNCE_DELAY);

      searchInput.addEventListener('input', (e) => debounced(e.target.value));
    }
  };

  // UI Enhancements
  const UI = {
    init: () => {
      // Add loading state to buttons
      document.querySelectorAll('form').forEach(form => {
        form.addEventListener('submit', (e) => {
          const btn = form.querySelector('button[type="submit"]');
          if (btn) {
            const original = btn.innerHTML;
            btn.innerHTML = '<span class="loading"></span> Processing...';
            btn.disabled = true;
            // Re-enable after 3s if not redirected (fallback)
            setTimeout(() => {
              btn.innerHTML = original;
              btn.disabled = false;
            }, 3000);
          }
        });
      });

      // Animate cards on scroll
      const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            entry.target.classList.add('fade-in');
          }
        });
      }, { threshold: 0.1 });

      document.querySelectorAll('.jumbotron, .jumbotron2, .card-modern').forEach(el => {
        observer.observe(el);
      });

      // Password visibility toggle
      document.querySelectorAll('input[type="password"]').forEach(input => {
        if (input.name === 'pwd' || input.placeholder.toLowerCase().includes('password')) {
          const wrapper = document.createElement('div');
          wrapper.className = 'position-relative';
          input.parentNode.insertBefore(wrapper, input);
          wrapper.appendChild(input);
          
          const toggle = document.createElement('button');
          toggle.type = 'button';
          toggle.className = 'btn btn-sm position-absolute';
          toggle.style.cssText = 'right:8px;top:50%;transform:translateY(-50%);background:transparent;border:none;';
          toggle.innerHTML = '👁️';
          toggle.onclick = () => {
            input.type = input.type === 'password' ? 'text' : 'password';
            toggle.innerHTML = input.type === 'password' ? '👁️' : '🙈';
          };
          wrapper.appendChild(toggle);
        }
      });
    }
  };

  // Global validation function for backward compatibility
  window.valid = function() {
    const form = document.forms['myForm'] || document.querySelector('form');
    if (!form) return true;

    const action = form.getAttribute('action') || '';
    if (action.includes('login')) return Validators.login(form);
    if (action.includes('reg.jsp') || form.querySelector('[name="userid"]')) return Validators.register(form);
    if (action.includes('stureg')) return Validators.student(form);
    if (action.includes('hrreg')) return Validators.company(form);
    
    // Generic check
    const usr = form.querySelector('[name="usr"]');
    const pwd = form.querySelector('[name="pwd"]');
    if (usr && pwd) return Validators.login(form);
    
    return true;
  };

  // Specific validators for new pages
  window.validateLogin = () => Validators.login(document.forms['myForm']);
  window.validateRegister = () => Validators.register(document.forms['myForm']);
  window.validateStudent = () => Validators.student(document.forms['myForm']);
  window.validateCompany = () => Validators.company(document.forms['myForm']);

  // Init on DOM ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
      Search.init();
      UI.init();
    });
  } else {
    Search.init();
    UI.init();
  }

  // Expose utils globally for debugging
  window.FindingUtils = Utils;

})();
