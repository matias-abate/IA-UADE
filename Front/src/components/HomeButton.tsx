import React from 'react';
import { useNavigate } from 'react-router-dom';
import './HomeButton.css';

export const HomeButton: React.FC = () => {
  const navigate = useNavigate();

  return (
    <button 
      className="home-button" 
      onClick={() => navigate('/')}
      aria-label="Volver al inicio"
    >
      🏠
    </button>
  );
};
