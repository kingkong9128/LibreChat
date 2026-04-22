import 'regenerator-runtime/runtime';
import { createRoot } from 'react-dom/client';
import './locales/i18n';
import App from './App';
import './style.css';
import './mobile.css';
import { ApiErrorBoundaryProvider } from './hooks/ApiErrorBoundaryContext';
import 'katex/dist/katex.min.css';
import 'katex/dist/contrib/copy-tex.js';

const __originalPostMessage = window.postMessage.bind(window);
window.postMessage = function(data, targetOrigin) {
  try {
    __originalPostMessage(data, targetOrigin);
  } catch {
  }
};

const __originalParentPostMessage = window.parent && window.parent.postMessage && window.parent.postMessage.bind(window.parent);
if (__originalParentPostMessage) {
  window.parent.postMessage = function(data, targetOrigin) {
    try {
      __originalParentPostMessage(data, targetOrigin);
    } catch {
    }
  };
}

const container = document.getElementById('root');
const root = createRoot(container);

window.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'SET_LIBRECHAT_TOKEN') {
    const token = event.data.token;
    if (token) {
      window.__accountexLibreChatToken = token;
    }
  }
});

root.render(
  <ApiErrorBoundaryProvider>
    <App />
  </ApiErrorBoundaryProvider>,
);
