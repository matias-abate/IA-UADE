import React, { useState } from 'react';
import { X, Save } from 'lucide-react';
import { TipoElectrodomestico, CasoCreateDTO } from '../../services/api';

interface NuevoCasoModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSubmit: (data: CasoCreateDTO) => void;
}

export default function NuevoCasoModal({ isOpen, onClose, onSubmit }: NuevoCasoModalProps) {
  const [formData, setFormData] = useState<CasoCreateDTO>({
    clienteNombre: '',
    clienteTelefono: '',
    tipo: TipoElectrodomestico.HELADERA,
    marca: '',
    modelo: '',
    antiguedad: 0,
    sintomaReportado: ''
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSubmit(formData);
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-2xl shadow-2xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
        <div className="sticky top-0 bg-white border-b border-gray-200 p-6 flex items-center justify-between rounded-t-2xl">
          <h2 className="text-2xl font-bold text-gray-800">Nuevo Caso de Diagnóstico</h2>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600 transition-colors"
          >
            <X className="w-6 h-6" />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="p-6 space-y-6">
          {/* Información del Cliente */}
          <div className="space-y-4">
            <h3 className="font-semibold text-lg text-gray-800 border-b pb-2">
              Información del Cliente
            </h3>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Nombre Completo *
              </label>
              <input
                type="text"
                required
                value={formData.clienteNombre}
                onChange={(e) => setFormData({ ...formData, clienteNombre: e.target.value })}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent transition-all"
                placeholder="Ej: Juan Pérez"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Teléfono *
              </label>
              <input
                type="tel"
                required
                value={formData.clienteTelefono}
                onChange={(e) => setFormData({ ...formData, clienteTelefono: e.target.value })}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent transition-all"
                placeholder="Ej: +54 11 1234-5678"
              />
            </div>
          </div>

          {/* Información del Electrodoméstico */}
          <div className="space-y-4">
            <h3 className="font-semibold text-lg text-gray-800 border-b pb-2">
              Información del Electrodoméstico
            </h3>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Tipo de Electrodoméstico *
              </label>
              <select
                required
                value={formData.tipo}
                onChange={(e) => setFormData({ ...formData, tipo: e.target.value as TipoElectrodomestico })}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent transition-all"
              >
                <option value={TipoElectrodomestico.HELADERA}>Heladera</option>
                <option value={TipoElectrodomestico.LAVARROPAS}>Lavarropas</option>
                <option value={TipoElectrodomestico.MICROONDAS}>Microondas</option>
              </select>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Marca *
                </label>
                <input
                  type="text"
                  required
                  value={formData.marca}
                  onChange={(e) => setFormData({ ...formData, marca: e.target.value })}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent transition-all"
                  placeholder="Ej: Samsung"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Modelo *
                </label>
                <input
                  type="text"
                  required
                  value={formData.modelo}
                  onChange={(e) => setFormData({ ...formData, modelo: e.target.value })}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent transition-all"
                  placeholder="Ej: RT38"
                />
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Antigüedad (años) *
              </label>
              <input
                type="number"
                required
                min="0"
                max="50"
                value={formData.antiguedad}
                onChange={(e) => setFormData({ ...formData, antiguedad: parseInt(e.target.value) })}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent transition-all"
                placeholder="Ej: 3"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Síntoma Reportado *
              </label>
              <textarea
                required
                rows={4}
                value={formData.sintomaReportado}
                onChange={(e) => setFormData({ ...formData, sintomaReportado: e.target.value })}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent transition-all resize-none"
                placeholder="Describa el problema que presenta el electrodoméstico..."
              />
            </div>
          </div>

          {/* Botones */}
          <div className="flex gap-3 pt-4 border-t">
            <button
              type="button"
              onClick={onClose}
              className="flex-1 px-6 py-3 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-all font-medium"
            >
              Cancelar
            </button>
            <button
              type="submit"
              className="flex-1 px-6 py-3 bg-gradient-to-r from-indigo-600 to-purple-600 text-white rounded-lg hover:from-indigo-700 hover:to-purple-700 transition-all shadow-lg hover:shadow-xl font-medium flex items-center justify-center gap-2"
            >
              <Save className="w-5 h-5" />
              Crear Caso
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}