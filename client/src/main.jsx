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
window.postMessage = function(data: unknown, targetOrigin?: string | Window) {
  try {
    __originalPostMessage(data, targetOrigin as string);
  } catch {
    // Silently suppress postMessage errors that occur when trying to
    // postMessage to a cross-origin parent window. This can happen when
    // embedded LibreChat code calls window.parent.postMessage with its own
    // origin as the target, which fails in an iframe context.
  }
};

const container = document.getElementById('root');
const root = createRoot(container);

window.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'SET_LIBRECHAT_TOKEN') {
    const token = event.data.token;
    if (token) {
      (window as typeof window & { __accountexLibreChatToken?: string }).__accountexLibreChatToken = token;
    }
  }
});

root.render(
  <ApiErrorBoundaryProvider>
    <App />
  </ApiErrorBoundaryProvider>,
);
