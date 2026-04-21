import 'regenerator-runtime/runtime';
import { createRoot } from 'react-dom/client';
import './locales/i18n';
import App from './App';
import './style.css';
import './mobile.css';
import { ApiErrorBoundaryProvider } from './hooks/ApiErrorBoundaryContext';
import 'katex/dist/katex.min.css';
import 'katex/dist/contrib/copy-tex.js';

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
