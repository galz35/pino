import Swal from 'sweetalert2';

const playSound = (type: 'success' | 'error' | 'info') => {
  try {
    const audio = new Audio(type === 'error' ? '/sounds/error.mp3' : '/sounds/ping.mp3');
    audio.play().catch(() => {}); // Ignorar si el navegador bloquea el auto-play
  } catch (e) {}
};

export const toast = {
  success: (title: string, text?: string) => {
    playSound('success');
    return Swal.fire({
      icon: 'success',
      title,
      text,
      toast: true,
      position: 'top-end',
      showConfirmButton: false,
      timer: 3000,
      timerProgressBar: true,
      background: '#f8fafc',
    });
  },
  error: (title: string, text?: string) => {
    playSound('error');
    return Swal.fire({
      icon: 'error',
      title,
      text,
      toast: true,
      position: 'top-end',
      showConfirmButton: false,
      timer: 4000,
      timerProgressBar: true,
      background: '#f8fafc',
    });
  },
  info: (title: string, text?: string) => {
    playSound('info');
    return Swal.fire({
      icon: 'info',
      title,
      text,
      toast: true,
      position: 'top-end',
      showConfirmButton: false,
      timer: 3000,
      timerProgressBar: true,
      background: '#f8fafc',
    });
  },
  warning: (title: string, text?: string) => {
    return Swal.fire({
      icon: 'warning',
      title,
      text,
      toast: true,
      position: 'top-end',
      showConfirmButton: false,
      timer: 3000,
      timerProgressBar: true,
      background: '#f8fafc',
    });
  }
};

export const alert = {
  confirm: (title: string, text: string) => {
    return Swal.fire({
      title,
      text,
      icon: 'question',
      showCancelButton: true,
      confirmButtonColor: '#2563eb',
      cancelButtonColor: '#ef4444',
      confirmButtonText: 'Confirmar',
      cancelButtonText: 'Cancelar',
      background: '#f8fafc',
      customClass: {
        popup: 'rounded-2xl border-none shadow-2xl',
        title: 'text-2xl font-black uppercase tracking-tight',
        confirmButton: 'rounded-xl px-8 py-3 font-bold',
        cancelButton: 'rounded-xl px-8 py-3 font-bold'
      }
    });
  },
  success: (title: string, text: string) => {
    playSound('success');
    return Swal.fire({
      title,
      text,
      icon: 'success',
      confirmButtonColor: '#2563eb',
      background: '#f8fafc',
      customClass: {
        popup: 'rounded-2xl border-none shadow-2xl',
        title: 'text-2xl font-black uppercase tracking-tight'
      }
    });
  },
  error: (title: string, text: string) => {
    playSound('error');
    return Swal.fire({
      title,
      text,
      icon: 'error',
      confirmButtonColor: '#2196f3',
      background: '#f8fafc',
      customClass: {
        popup: 'rounded-2xl border-none shadow-2xl',
        title: 'text-2xl font-black uppercase tracking-tight'
      }
    });
  }
};

export default Swal;
