export const CLASSES = [
  { value: '1', label: '1st' }, { value: '2', label: '2nd' },
  { value: '3', label: '3rd' }, { value: '4', label: '4th' },
  { value: '5', label: '5th' }, { value: '6', label: '6th' },
  { value: '7', label: '7th' }, { value: '8', label: '8th' },
  { value: '9', label: '9th' }, { value: '10', label: '10th' }
]
export const classLabel = value => CLASSES.find(c => c.value === String(value))?.label || `Class ${value}`
