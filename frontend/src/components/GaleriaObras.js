import React from 'react';
import CardObra from './CardObra';
import './GaleriaObras.css';

function GaleriaObras({ obras }) {
  if (obras.length === 0) {
    return (
      <div className="galeria-vazia">
        <p>Nenhuma obra encontrada com os filtros selecionados.</p>
      </div>
    );
  }

  return (
    <div className="galeria-container">
      <div className="galeria-grid">
        {obras.map(obra => (
          <CardObra key={obra.id} obra={obra} />
        ))}
      </div>
    </div>
  );
}

export default GaleriaObras;
