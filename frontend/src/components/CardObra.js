import React, { useState } from 'react';
import './CardObra.css';

function CardObra({ obra }) {
  const [imagemCarregada, setImagemCarregada] = useState(false);
  const [erroImagem, setErroImagem] = useState(false);

  return (
    <div className="card-obra">
      <div className="card-imagem-container">
        {!imagemCarregada && !erroImagem && (
          <div className="card-loading">Carregando...</div>
        )}
        
        {erroImagem ? (
          <div className="card-erro-imagem">
            <span>🖼️</span>
            <p>Imagem indisponível</p>
          </div>
        ) : (
          <img 
            src={obra.imagem} 
            alt={obra.nome}
            className={`card-imagem ${imagemCarregada ? 'carregada' : ''}`}
            onLoad={() => setImagemCarregada(true)}
            onError={() => setErroImagem(true)}
          />
        )}
        
        <div className="card-estilo-badge">{obra.estilo}</div>
      </div>
      
      <div className="card-conteudo">
        <h3 className="card-titulo">{obra.nome}</h3>
        <p className="card-artista">
          <span className="icone-artista">👨‍🎨</span>
          {obra.artista}
        </p>
        <p className="card-ano">
          <span className="icone-ano">📅</span>
          {obra.ano}
        </p>
        <p className="card-descricao">{obra.descricao}</p>
      </div>
    </div>
  );
}

export default CardObra;
