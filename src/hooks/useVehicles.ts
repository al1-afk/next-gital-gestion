import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { toast } from 'sonner'
import { api } from '@/lib/api'
import { currentTenantIdForCache } from '@/lib/authToken'

/* ── Types ──────────────────────────────────────────────────── */
export type VehicleType  = 'voiture' | 'utilitaire' | 'fourgon' | 'moto' | 'camion' | 'autre'
export type FuelType     = 'diesel' | 'essence' | 'hybride' | 'electrique' | 'autre'
export type VehicleStatut = 'actif' | 'panne' | 'vendu' | 'reforme'
export type MaintType    = 'vidange' | 'revision' | 'reparation' | 'pneus' | 'freins' | 'batterie' | 'autre'
export type DocType      = 'assurance' | 'visite_technique' | 'vignette' | 'carte_grise' | 'autre'

export interface Vehicle {
  id:                   string
  immatriculation:      string
  marque:               string
  modele:               string
  type:                 VehicleType
  annee:                number | null
  vin:                  string | null
  carburant_type:       FuelType
  date_achat:           string | null
  prix_achat:           number | null
  kilometrage:          number
  conducteur_principal: string | null
  image_url:            string | null
  notes:                string | null
  statut:               VehicleStatut
  created_at:           string
  updated_at:           string
  /* joined */
  fuel_month_cost?:  number
  maint_month_cost?: number
}

export interface FuelLog {
  id:           string
  vehicle_id:   string
  date:         string
  kilometrage:  number
  litres:       number
  prix_total:   number
  prix_litre:   number
  station:      string | null
  conducteur:   string | null
  is_full:      boolean
  notes:        string | null
  created_at:   string
  /* joined */
  immatriculation?: string
  marque?:          string
  modele?:          string
}

export interface Maintenance {
  id:             string
  vehicle_id:     string
  date:           string
  type:           MaintType
  description:    string
  garage:         string | null
  kilometrage:    number | null
  montant:        number
  prochaine_date: string | null
  prochaine_km:   number | null
  notes:          string | null
  created_at:     string
  /* joined */
  immatriculation?: string
  marque?:          string
  modele?:          string
}

export interface VehicleDocument {
  id:         string
  vehicle_id: string
  type:       DocType
  numero:     string | null
  emetteur:   string | null
  date_debut: string | null
  date_fin:   string
  montant:    number | null
  notes:      string | null
  created_at: string
  /* joined */
  immatriculation?: string
  marque?:          string
  modele?:          string
  days_left?:       number
}

export interface VehicleStats {
  kilometrage:      number
  prix_achat:       number | null
  total_litres:     number
  total_fuel_cost:  number
  pleins:           number
  km_range:         number
  total_maint_cost: number
  interventions:    number
  trips:            number
  km_trips:         number
  conso_l_100km:    number
  cost_per_km:      number
}

export interface VehicleAlerts {
  documents: Array<VehicleDocument & {
    vehicle_id: string; marque: string; modele: string; immatriculation: string
  }>
  maintenance: Array<{
    id:               string
    type:             string
    description:      string
    prochaine_date:   string | null
    prochaine_km:     number | null
    vehicle_id:       string
    marque:           string
    modele:           string
    immatriculation:  string
    kilometrage:      number
    days_left:        number | null
    km_left:          number | null
  }>
}

const tk = (...k: (string | number | null)[]) =>
  ['vehicles', currentTenantIdForCache(), ...k] as const

/* ═════════ VEHICLES ═════════ */
export function useVehicles() {
  return useQuery<Vehicle[]>({
    queryKey: tk('list'),
    queryFn:  () => api.get('/api/vehicles'),
    staleTime: 1000 * 60 * 2,
  })
}
export function useVehicle(id: string | null) {
  return useQuery<Vehicle>({
    queryKey: tk('detail', id),
    queryFn:  () => api.get(`/api/vehicles/${id}`),
    enabled:  !!id,
    staleTime: 1000 * 60,
  })
}
export function useVehicleStats(id: string | null) {
  return useQuery<VehicleStats>({
    queryKey: tk('stats', id),
    queryFn:  () => api.get(`/api/vehicles/${id}/stats`),
    enabled:  !!id,
  })
}
export function useCreateVehicle() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (data: Partial<Vehicle>) => api.post<Vehicle>('/api/vehicles', data),
    onSuccess:  () => { qc.invalidateQueries({ queryKey: ['vehicles'] }); toast.success('Véhicule ajouté') },
    onError:    (e: any) => toast.error(e?.message ?? 'Erreur'),
  })
}
export function useUpdateVehicle() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: ({ id, ...data }: Partial<Vehicle> & { id: string }) =>
      api.patch<Vehicle>(`/api/vehicles/${id}`, data),
    onSuccess:  () => { qc.invalidateQueries({ queryKey: ['vehicles'] }); toast.success('Véhicule mis à jour') },
    onError:    (e: any) => toast.error(e?.message ?? 'Erreur'),
  })
}
export function useDeleteVehicle() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (id: string) => api.delete(`/api/vehicles/${id}`),
    onSuccess:  () => { qc.invalidateQueries({ queryKey: ['vehicles'] }); toast.success('Véhicule supprimé') },
    onError:    (e: any) => toast.error(e?.message ?? 'Erreur'),
  })
}

/* ═════════ FUEL ═════════ */
export function useAllFuelLogs() {
  return useQuery<FuelLog[]>({
    queryKey: tk('fuel-all'),
    queryFn:  () => api.get('/api/vehicles/fuel/all'),
    staleTime: 1000 * 60,
  })
}
export function useVehicleFuel(id: string | null) {
  return useQuery<FuelLog[]>({
    queryKey: tk('fuel', id),
    queryFn:  () => api.get(`/api/vehicles/${id}/fuel`),
    enabled:  !!id,
  })
}
export function useCreateFuelLog() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: ({ vehicle_id, ...data }: Partial<FuelLog> & { vehicle_id: string }) =>
      api.post<FuelLog>(`/api/vehicles/${vehicle_id}/fuel`, data),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ['vehicles'] }); toast.success('Plein enregistré') },
    onError:   (e: any) => toast.error(e?.message ?? 'Erreur'),
  })
}
export function useDeleteFuelLog() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (id: string) => api.delete(`/api/vehicles/fuel/${id}`),
    onSuccess:  () => { qc.invalidateQueries({ queryKey: ['vehicles'] }); toast.success('Plein supprimé') },
    onError:    (e: any) => toast.error(e?.message ?? 'Erreur'),
  })
}

/* ═════════ MAINTENANCE ═════════ */
export function useAllMaintenance() {
  return useQuery<Maintenance[]>({
    queryKey: tk('maint-all'),
    queryFn:  () => api.get('/api/vehicles/maintenance/all'),
    staleTime: 1000 * 60,
  })
}
export function useVehicleMaintenance(id: string | null) {
  return useQuery<Maintenance[]>({
    queryKey: tk('maint', id),
    queryFn:  () => api.get(`/api/vehicles/${id}/maintenance`),
    enabled:  !!id,
  })
}
export function useCreateMaintenance() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: ({ vehicle_id, ...data }: Partial<Maintenance> & { vehicle_id: string }) =>
      api.post<Maintenance>(`/api/vehicles/${vehicle_id}/maintenance`, data),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ['vehicles'] }); toast.success('Intervention enregistrée') },
    onError:   (e: any) => toast.error(e?.message ?? 'Erreur'),
  })
}
export function useDeleteMaintenance() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (id: string) => api.delete(`/api/vehicles/maintenance/${id}`),
    onSuccess:  () => { qc.invalidateQueries({ queryKey: ['vehicles'] }); toast.success('Intervention supprimée') },
    onError:    (e: any) => toast.error(e?.message ?? 'Erreur'),
  })
}

/* ═════════ DOCUMENTS ═════════ */
export function useAllDocuments() {
  return useQuery<VehicleDocument[]>({
    queryKey: tk('docs-all'),
    queryFn:  () => api.get('/api/vehicles/documents/all'),
    staleTime: 1000 * 60,
  })
}
export function useVehicleDocuments(id: string | null) {
  return useQuery<VehicleDocument[]>({
    queryKey: tk('docs', id),
    queryFn:  () => api.get(`/api/vehicles/${id}/documents`),
    enabled:  !!id,
  })
}
export function useCreateDocument() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: ({ vehicle_id, ...data }: Partial<VehicleDocument> & { vehicle_id: string }) =>
      api.post<VehicleDocument>(`/api/vehicles/${vehicle_id}/documents`, data),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ['vehicles'] }); toast.success('Document enregistré') },
    onError:   (e: any) => toast.error(e?.message ?? 'Erreur'),
  })
}
export function useDeleteDocument() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: (id: string) => api.delete(`/api/vehicles/documents/${id}`),
    onSuccess:  () => { qc.invalidateQueries({ queryKey: ['vehicles'] }); toast.success('Document supprimé') },
    onError:    (e: any) => toast.error(e?.message ?? 'Erreur'),
  })
}

/* ═════════ ALERTS ═════════ */
export function useVehicleAlerts() {
  return useQuery<VehicleAlerts>({
    queryKey: tk('alerts'),
    queryFn:  () => api.get('/api/vehicles/alerts'),
    staleTime: 1000 * 60,
  })
}

/* ═════════ GPS POSITIONS ═════════ */
export interface VehiclePosition {
  id?:          string
  vehicle_id:   string
  recorded_at:  string
  lat:          number
  lng:          number
  speed?:       number | null
  heading?:     number | null
  altitude?:    number | null
  accuracy?:    number | null
  driver?:      string | null
  source?:      'browser' | 'device' | 'manual'
  /* joined on /latest */
  marque?:          string
  modele?:          string
  immatriculation?: string
  statut?:          string
  type?:            string
  image_url?:       string | null
  seconds_ago?:     number
}

export function useFleetPositions(refetchMs = 15_000) {
  return useQuery<VehiclePosition[]>({
    queryKey: tk('positions-latest'),
    queryFn:  () => api.get('/api/vehicles/positions/latest'),
    refetchInterval: refetchMs,
    staleTime: 1000 * 5,
  })
}

export function useVehiclePositions(id: string | null, since?: string) {
  return useQuery<VehiclePosition[]>({
    queryKey: tk('positions', id, since ?? null),
    queryFn:  () => api.get(`/api/vehicles/${id}/positions${since ? `?since=${encodeURIComponent(since)}` : ''}`),
    enabled:  !!id,
    refetchInterval: 30_000,
  })
}

export function usePushPosition() {
  const qc = useQueryClient()
  return useMutation({
    mutationFn: ({ vehicle_id, ...data }: Partial<VehiclePosition> & { vehicle_id: string; lat: number; lng: number }) =>
      api.post(`/api/vehicles/${vehicle_id}/positions`, data),
    onSuccess: () => qc.invalidateQueries({ queryKey: ['vehicles'] }),
  })
}
