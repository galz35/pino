import React, { Component, ErrorInfo, ReactNode } from 'react';
import { AlertTriangle, RefreshCcw } from 'lucide-react';
import { Button } from '@/components/ui/button';

interface Props {
  children?: ReactNode;
  fallback?: ReactNode;
}

interface State {
  hasError: boolean;
}

class ErrorBoundary extends Component<Props, State> {
  public state: State = {
    hasError: false
  };

  public static getDerivedStateFromError(_: Error): State {
    return { hasError: true };
  }

  public componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('Uncaught error:', error, errorInfo);
  }

  public render() {
    if (this.state.hasError) {
      return this.props.fallback || (
        <div className="flex h-screen w-full flex-col items-center justify-center bg-slate-50 p-6 text-center">
          <div className="mb-6 rounded-full bg-red-100 p-6 shadow-[inset_4px_4px_8px_#d1d9e6,inset_-4px_-4px_8px_#ffffff]">
            <AlertTriangle className="h-12 w-12 text-red-500" />
          </div>
          <h1 className="mb-2 text-2xl font-black uppercase tracking-tighter text-slate-800">Ups! Algo salió mal</h1>
          <p className="mb-8 max-w-md text-sm font-medium text-slate-500">
            La aplicación encontró un error inesperado. Hemos registrado este incidente para solucionarlo.
          </p>
          <Button 
            onClick={() => window.location.reload()} 
            className="h-12 rounded-2xl bg-primary px-8 font-black uppercase tracking-widest shadow-[8px_8px_16px_#ccced1,-8px_-8px_16px_#ffffff] hover:shadow-none"
          >
            <RefreshCcw className="mr-2 h-4 w-4" />
            Recargar Aplicación
          </Button>
        </div>
      );
    }

    return this.props.children;
  }
}

export default ErrorBoundary;
