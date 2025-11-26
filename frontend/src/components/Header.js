import React from 'react';
import './Header.css';

function Header() {
  return (
    <header className="header">
      <div className="header-content">
        <h1 className="header-title">
          <span className="icon">🎨</span>
          Galeria de Artes Online
        </h1>
        <p className="header-subtitle">
          Explore obras-primas da história da arte
        </p>
      </div>
    </header>
  );
}

export default Header;
