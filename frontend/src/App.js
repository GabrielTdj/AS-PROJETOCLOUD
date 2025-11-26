import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './App.css';
import GaleriaObras from './components/GaleriaObras';
import Header from './components/Header';
import Loading from './components/Loading';
import ErrorMessage from './components/ErrorMessage';

// Configurar a URL da API
// Em produção, usar variável de ambiente
const API_URL = process.env.REACT_APP_API_URL || 'https://SEU_FUNCTION_APP.azurewebsites.net/api';

function App() {
  const [obras, setObras] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [filtroEstilo, setFiltroEstilo] = useState('todos');
  const [estilos, setEstilos] = useState([]);

  useEffect(() => {
    carregarObras();
  }, []);

  const carregarObras = async () => {
    setLoading(true);
    setError(null);
    
    try {
      const response = await axios.get(`${API_URL}/obras`);
      setObras(response.data);
      
      // Extrair estilos únicos
      const estilosUnicos = [...new Set(response.data.map(obra => obra.estilo))];
      setEstilos(estilosUnicos);
      
    } catch (err) {
      console.error('Erro ao carregar obras:', err);
      setError('Não foi possível carregar as obras. Verifique a conexão com a API.');
    } finally {
      setLoading(false);
    }
  };

  const filtrarObras = () => {
    if (filtroEstilo === 'todos') {
      return obras;
    }
    return obras.filter(obra => obra.estilo === filtroEstilo);
  };

  const obrasFiltradas = filtrarObras();

  return (
    <div className="App">
      <Header />
      
      <main className="main-content">
        <div className="filtros-container">
          <div className="filtro-grupo">
            <label htmlFor="filtro-estilo">Filtrar por estilo:</label>
            <select 
              id="filtro-estilo"
              value={filtroEstilo} 
              onChange={(e) => setFiltroEstilo(e.target.value)}
              className="filtro-select"
            >
              <option value="todos">Todos os Estilos</option>
              {estilos.map(estilo => (
                <option key={estilo} value={estilo}>{estilo}</option>
              ))}
            </select>
          </div>
          
          <div className="info-contador">
            {obrasFiltradas.length} {obrasFiltradas.length === 1 ? 'obra' : 'obras'}
          </div>
        </div>

        {loading && <Loading />}
        {error && <ErrorMessage message={error} onRetry={carregarObras} />}
        {!loading && !error && <GaleriaObras obras={obrasFiltradas} />}
      </main>

      <footer className="footer">
        <p>© 2025 Galeria de Artes Online | Desenvolvido com Azure Cloud</p>
      </footer>
    </div>
  );
}

export default App;
