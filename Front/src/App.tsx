import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import './App.css';
import Dashboard from './components/Dashboard/Dashboard';
import DiagnosticWizard from './components/Diagnostic/DiagnosticWizard';
import Result from './components/Result/Result';
import { Wrench } from 'lucide-react';

function App() {
  return (
    <Router>
      <div className="App min-h-screen bg-gradient-to-br from-blue-50 via-indigo-50 to-purple-50 w-full">
        <header className="bg-white/80 backdrop-blur-md shadow-lg border-b border-indigo-100 sticky top-0 z-50 w-full">
          <div className="max-w-[1920px] mx-auto px-4 sm:px-6 lg:px-8 py-5">
            <div className="flex items-center gap-3">
              <div className="bg-gradient-to-br from-indigo-600 to-purple-600 p-3 rounded-xl shadow-lg">
                <Wrench className="w-6 h-6 text-white" />
              </div>
              <div>
                <h1 className="text-2xl font-bold bg-gradient-to-r from-indigo-600 to-purple-600 bg-clip-text text-transparent">
                  Sistema Experto
                </h1>
                <p className="text-sm text-gray-600">Diagnóstico Inteligente de Electrodomésticos</p>
              </div>
            </div>
          </div>
        </header>
        <main className="max-w-[1920px] mx-auto px-4 sm:px-6 lg:px-8 py-6 w-full">
          <Routes>
            <Route path="/" element={<Dashboard />} />
            <Route path="/diagnostico/:id" element={<DiagnosticWizard />} />
            <Route path="/resultado/:id" element={<Result />} />
          </Routes>
        </main>
        <footer className="mt-12 py-6 text-center text-gray-500 text-sm w-full">
          <p>© 2024 Sistema Experto - Diagnóstico Inteligente</p>
        </footer>
      </div>
    </Router>
  );
}

export default App;