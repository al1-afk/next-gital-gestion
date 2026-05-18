/**
 * /my-space/profile — view/edit profile (limited) + password change.
 */
import { useState, useEffect } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { Loader2, Save, Lock, Mail, Phone, Briefcase, Eye, EyeOff } from 'lucide-react'
import { mySpaceApi } from '@/lib/api'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/tabs'
import { toast } from 'sonner'
import { SOP_CATEGORY_BY_KEY } from '@/lib/sopCategories'

export default function MyProfile() {
  const qc = useQueryClient()
  const { data: profile, isLoading } = useQuery<any>({
    queryKey: ['my-space', 'profile'],
    queryFn:  () => mySpaceApi.profile(),
  })

  const [telephone, setTelephone] = useState('')
  useEffect(() => { setTelephone(profile?.telephone ?? '') }, [profile])

  const updateProfile = useMutation({
    mutationFn: (data: { telephone?: string; avatar_url?: string }) => mySpaceApi.updateProfile(data),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['my-space', 'profile'] })
      toast.success('Profil mis à jour')
    },
    onError: (e: any) => toast.error(e?.message ?? 'Erreur'),
  })

  if (isLoading || !profile) {
    return <div className="flex justify-center py-12"><Loader2 className="w-6 h-6 animate-spin text-blue-600" /></div>
  }

  const initials = `${profile.first_name?.[0] ?? ''}${profile.last_name?.[0] ?? ''}`.toUpperCase()

  return (
    <div className="space-y-5 max-w-3xl">
      <div>
        <h1 className="text-2xl font-bold text-slate-900 dark:text-slate-100">Mon profil</h1>
        <p className="text-sm text-slate-500 dark:text-slate-400">Gérez vos informations et votre mot de passe.</p>
      </div>

      <Tabs defaultValue="info">
        <TabsList>
          <TabsTrigger value="info">Informations</TabsTrigger>
          <TabsTrigger value="access">Mes accès</TabsTrigger>
          <TabsTrigger value="password">Mot de passe</TabsTrigger>
        </TabsList>

        <TabsContent value="info" className="space-y-4">
          <div className="bg-white dark:bg-slate-900 rounded-xl border border-slate-200 dark:border-slate-800 p-5">
            <div className="flex items-center gap-4 mb-5">
              <div className="w-16 h-16 rounded-full bg-gradient-to-br from-violet-500 to-fuchsia-500 flex items-center justify-center text-white text-xl font-bold">
                {initials}
              </div>
              <div>
                <div className="text-lg font-semibold text-slate-900 dark:text-slate-100">
                  {profile.first_name} {profile.last_name}
                </div>
                <div className="text-sm text-slate-500 dark:text-slate-400">{profile.job_title || 'Membre'}</div>
              </div>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <Field icon={Mail} label="Email" value={profile.email} readOnly />
              <Field icon={Briefcase} label="Poste" value={profile.job_title || '—'} readOnly />
              <Field icon={Phone} label="Téléphone" value={telephone} onChange={setTelephone} placeholder="+212 6XX XX XX XX" />
              <Field icon={Briefcase} label="Type" value={
                profile.member_type === 'employee'  ? 'Employé' :
                profile.member_type === 'trainer'   ? 'Formateur' :
                profile.member_type === 'freelance' ? 'Freelance' : profile.member_type
              } readOnly />
            </div>

            <div className="mt-5 flex justify-end">
              <Button
                onClick={() => updateProfile.mutate({ telephone })}
                disabled={updateProfile.isPending || telephone === (profile.telephone ?? '')}
              >
                {updateProfile.isPending ? <Loader2 className="w-4 h-4 animate-spin mr-2" /> : <Save className="w-4 h-4 mr-2" />}
                Enregistrer
              </Button>
            </div>
          </div>
        </TabsContent>

        <TabsContent value="access" className="space-y-4">
          <div className="bg-white dark:bg-slate-900 rounded-xl border border-slate-200 dark:border-slate-800 p-5">
            <h3 className="text-sm font-semibold text-slate-900 dark:text-slate-100 mb-3">Catégories SOPs accessibles</h3>
            {profile.access.length === 0 ? (
              <p className="text-sm text-slate-500 dark:text-slate-400">Aucune catégorie ne vous est encore assignée.</p>
            ) : (
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                {profile.access.map((a: any) => {
                  const meta = SOP_CATEGORY_BY_KEY[a.category]
                  return (
                    <div key={a.category} className="flex items-center gap-3 p-3 rounded-lg bg-slate-50 dark:bg-slate-800/40">
                      <span className="text-lg">{meta?.emoji ?? '📚'}</span>
                      <div className="flex-1">
                        <div className="text-sm font-medium text-slate-900 dark:text-slate-100">{meta?.label ?? a.category}</div>
                        <div className="text-xs text-slate-500 dark:text-slate-400">
                          {a.level === 'edit' ? 'Édition' : a.level === 'complete' ? 'Checklist' : 'Lecture'}
                        </div>
                      </div>
                    </div>
                  )
                })}
              </div>
            )}
            <p className="text-xs text-slate-500 dark:text-slate-400 mt-4">
              Pour demander un nouvel accès, contactez votre administrateur.
            </p>
          </div>
        </TabsContent>

        <TabsContent value="password" className="space-y-4">
          <PasswordChange />
        </TabsContent>
      </Tabs>
    </div>
  )
}

function Field({ icon: Icon, label, value, onChange, readOnly, placeholder }: {
  icon: React.ElementType
  label: string
  value: string
  onChange?: (v: string) => void
  readOnly?: boolean
  placeholder?: string
}) {
  return (
    <div>
      <label className="text-xs font-medium text-slate-600 dark:text-slate-400 mb-1.5 flex items-center gap-1.5">
        <Icon className="w-3.5 h-3.5" /> {label}
      </label>
      <Input
        value={value}
        onChange={onChange ? e => onChange(e.target.value) : undefined}
        readOnly={readOnly}
        placeholder={placeholder}
        className={readOnly ? 'bg-slate-50 dark:bg-slate-900/60' : ''}
      />
    </div>
  )
}

function PasswordChange() {
  const [current, setCurrent] = useState('')
  const [next, setNext]       = useState('')
  const [confirm, setConfirm] = useState('')
  const [showAll, setShowAll] = useState(false)

  const change = useMutation({
    mutationFn: () => mySpaceApi.changePassword(current, next),
    onSuccess: () => {
      toast.success('Mot de passe modifié')
      setCurrent(''); setNext(''); setConfirm('')
    },
    onError: (e: any) => toast.error(e?.message ?? 'Erreur'),
  })

  const canSubmit = current && next.length >= 8 && /[0-9]/.test(next) && next === confirm && !change.isPending

  return (
    <div className="bg-white dark:bg-slate-900 rounded-xl border border-slate-200 dark:border-slate-800 p-5 max-w-md">
      <div className="flex items-center gap-2 mb-4">
        <Lock className="w-5 h-5 text-slate-500" />
        <h3 className="text-sm font-semibold text-slate-900 dark:text-slate-100">Changer mon mot de passe</h3>
      </div>

      <div className="space-y-3">
        <div>
          <label className="text-xs font-medium text-slate-600 dark:text-slate-400 mb-1.5 block">Ancien mot de passe</label>
          <Input type={showAll ? 'text' : 'password'} value={current} onChange={e => setCurrent(e.target.value)} autoComplete="current-password" />
        </div>
        <div>
          <label className="text-xs font-medium text-slate-600 dark:text-slate-400 mb-1.5 block">Nouveau mot de passe</label>
          <Input type={showAll ? 'text' : 'password'} value={next} onChange={e => setNext(e.target.value)} autoComplete="new-password" placeholder="Min. 8 caractères + 1 chiffre" />
        </div>
        <div>
          <label className="text-xs font-medium text-slate-600 dark:text-slate-400 mb-1.5 block">Confirmer</label>
          <Input type={showAll ? 'text' : 'password'} value={confirm} onChange={e => setConfirm(e.target.value)} autoComplete="new-password" />
          {confirm && next !== confirm && (
            <p className="text-xs text-red-600 mt-1">Les mots de passe ne correspondent pas</p>
          )}
        </div>
        <label className="flex items-center gap-2 text-xs text-slate-500 dark:text-slate-400 cursor-pointer">
          <input type="checkbox" checked={showAll} onChange={() => setShowAll(v => !v)} />
          {showAll ? <EyeOff className="w-3.5 h-3.5" /> : <Eye className="w-3.5 h-3.5" />}
          Afficher les mots de passe
        </label>
        <Button onClick={() => change.mutate()} disabled={!canSubmit} className="w-full">
          {change.isPending ? <Loader2 className="w-4 h-4 animate-spin mr-2" /> : <Save className="w-4 h-4 mr-2" />}
          Mettre à jour
        </Button>
      </div>
    </div>
  )
}
