

import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
} from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Alert, AlertTitle, AlertDescription } from '@/components/ui/alert';
import { useToast } from '@/hooks/use-toast';
import { useEffect, useRef, useState, useCallback } from 'react';
import { BrowserMultiFormatReader, NotFoundException } from '@zxing/library';

interface BarcodeScannerDialogProps {
  isOpen: boolean;
  onClose: () => void;
  onBarcodeScan: (barcode: string) => void;
}

export function BarcodeScannerDialog({ isOpen, onClose, onBarcodeScan }: BarcodeScannerDialogProps) {
  const videoRef = useRef<HTMLVideoElement>(null);
  const [hasCameraPermission, setHasCameraPermission] = useState<boolean | null>(null);
  const { toast } = useToast();
  const codeReader = useRef(new BrowserMultiFormatReader());

  const startScanning = useCallback(() => {
    if (videoRef.current && hasCameraPermission) {
      codeReader.current.decodeFromVideoDevice(null, videoRef.current, (result, err) => {
        if (result) {
          onBarcodeScan(result.getText());
          onClose();
        }
        if (err && !(err instanceof NotFoundException)) {
          console.error('Barcode scan error:', err);
          toast({
            variant: 'destructive',
            title: 'Error de Escaneo',
            description: 'No se pudo leer el código de barras.',
          });
        }
      });
    }
  }, [hasCameraPermission, onBarcodeScan, onClose, toast]);

  useEffect(() => {
    const reader = codeReader.current;

    const getCameraPermission = async () => {
      try {
        const stream = await navigator.mediaDevices.getUserMedia({ video: { facingMode: 'environment' } });
        setHasCameraPermission(true);
        if (videoRef.current) {
          videoRef.current.srcObject = stream;
        }
      } catch (error) {
        console.error('Error accessing camera:', error);
        setHasCameraPermission(false);
        toast({
          variant: 'destructive',
          title: 'Acceso a la Cámara Denegado',
          description: 'Por favor, habilita los permisos de cámara en tu navegador.',
        });
        onClose();
      }
    };

    if (isOpen) {
      getCameraPermission();
    }

    return () => {
      // Detener el escaneo y la cámara cuando el diálogo se cierra o desmonta
      reader.reset();
      if (videoRef.current && videoRef.current.srcObject) {
        // eslint-disable-next-line react-hooks/exhaustive-deps
        (videoRef.current.srcObject as MediaStream).getTracks().forEach(track => track.stop());
      }
    };
  }, [isOpen, onClose, toast]);

  useEffect(() => {
    if (isOpen && hasCameraPermission) {
      startScanning();
    }
  }, [isOpen, hasCameraPermission, startScanning]);

  if (!isOpen) {
    return null;
  }

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Escanear Código de Barras</DialogTitle>
          <DialogDescription>
            Apunta la cámara al código de barras del producto.
          </DialogDescription>
        </DialogHeader>
        <div className="relative aspect-video">
          <video ref={videoRef} className="w-full h-full rounded-md" autoPlay muted playsInline />
          {hasCameraPermission === false && (
            <Alert variant="destructive">
              <AlertTitle>Cámara No Disponible</AlertTitle>
              <AlertDescription>
                No se pudo acceder a la cámara. Revisa los permisos.
              </AlertDescription>
            </Alert>
          )}
        </div>
        <Button variant="outline" onClick={onClose} className="mt-4">
          Cancelar
        </Button>
      </DialogContent>
    </Dialog>
  );
}
