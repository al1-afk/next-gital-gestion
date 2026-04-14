import { useState } from 'react'
import { Settings, User, Bell, Shield, Database, Globe, Save } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/tabs'
import { toast } from 'sonner'

export default function Parametres() {
  const [profile, setProfile] = useState({
    nom: 'NextGital Admin',
    email: 'admin@nextgital.com',
    telephone: '0661000000',
    entreprise: 'NextGital Agency',
    adresse: 'Casablanca, Maroc',
    devise: 'MAD',
    tva_defaut: '20',
  })

  return (
    <div className="space-y-6 animate-fade-in max-w-4xl">
      <div>
        <h1 className="page-title flex items-center gap-2">
          <Settings className="w-6 h-6 text-blue-400" />
          Paramètres
        </h1>
        <p className="text-slate-500 text-sm mt-1">Configuration de votre espace NextGital</p>
      </div>

      <Tabs defaultValue="profil">
        <TabsList>
          <TabsTrigger value="profil">Profil</TabsTrigger>
          <TabsTrigger value="entreprise">Entreprise</TabsTrigger>
          <TabsTrigger value="notifications">Notifications</TabsTrigger>
          <TabsTrigger value="securite">Sécurité</TabsTrigger>
        </TabsList>

        <TabsContent value="profil">
          <div className="card p-6 space-y-5">
            <h2 className="section-title flex items-center gap-2"><User className="w-4 h-4 text-blue-400" />Informations personnelles</h2>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-1.5"><label className="form-label">Nom complet</label><Input value={profile.nom} onChange={e => setProfile(p => ({ ...p, nom: e.target.value }))} /></div>
              <div className="space-y-1.5"><label className="form-label">Email</label><Input type="email" value={profile.email} onChange={e => setProfile(p => ({ ...p, email: e.target.value }))} /></div>
              <div className="space-y-1.5"><label className="form-label">Téléphone</label><Input value={profile.telephone} onChange={e => setProfile(p => ({ ...p, telephone: e.target.value }))} /></div>
              <div className="space-y-1.5"><label className="form-label">Entreprise</label><Input value={profile.entreprise} onChange={e => setProfile(p => ({ ...p, entreprise: e.target.value }))} /></div>
            </div>
            <Button onClick={() => toast.success('Profil mis à jour')}><Save className="w-4 h-4" />Sauvegarder</Button>
          </div>
        </TabsContent>

        <TabsContent value="entreprise">
          <div className="card p-6 space-y-5">
            <h2 className="section-title flex items-center gap-2"><Globe className="w-4 h-4 text-blue-400" />Configuration entreprise</h2>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-1.5"><label className="form-label">Raison sociale</label><Input value={profile.entreprise} onChange={e => setProfile(p => ({ ...p, entreprise: e.target.value }))} /></div>
              <div className="space-y-1.5"><label className="form-label">Adresse</label><Input value={profile.adresse} onChange={e => setProfile(p => ({ ...p, adresse: e.target.value }))} /></div>
              <div className="space-y-1.5"><label className="form-label">Devise par défaut</label><Input value={profile.devise} onChange={e => setProfile(p => ({ ...p, devise: e.target.value }))} /></div>
              <div className="space-y-1.5"><label className="form-label">TVA par défaut (%)</label><Input value={profile.tva_defaut} onChange={e => setProfile(p => ({ ...p, tva_defaut: e.target.value }))} /></div>
            </div>
            <Button onClick={() => toast.success('Paramètres sauvegardés')}><Save className="w-4 h-4" />Sauvegarder</Button>
          </div>
        </TabsContent>

        <TabsContent value="notifications">
          <div className="card p-6 space-y-4">
            <h2 className="section-title flex items-center gap-2"><Bell className="w-4 h-4 text-blue-400" />Notifications</h2>
            {[
              { label: 'Renouvellements domaines (30j avant)', enabled: true },
              { label: 'Factures impayées (7j après échéance)', enabled: true },
              { label: 'Prospects sans relance (14j)', enabled: true },
              { label: 'Rapport mensuel automatique', enabled: false },
              { label: 'Alertes abonnements', enabled: true },
            ].map((n, i) => (
              <div key={i} className="flex items-center justify-between p-3 bg-muted rounded-lg">
                <span className="text-sm text-foreground">{n.label}</span>
                <button
                  className={`w-10 h-5 rounded-full transition-all ${n.enabled ? 'bg-[#378ADD]' : 'bg-border'} relative`}
                  onClick={() => toast.success('Préférence mise à jour')}
                >
                  <div className={`w-4 h-4 bg-white rounded-full absolute top-0.5 transition-all ${n.enabled ? 'right-0.5' : 'left-0.5'}`} />
                </button>
              </div>
            ))}
          </div>
        </TabsContent>

        <TabsContent value="securite">
          <div className="card p-6 space-y-5">
            <h2 className="section-title flex items-center gap-2"><Shield className="w-4 h-4 text-blue-400" />Sécurité</h2>
            <div className="space-y-4">
              <div className="space-y-1.5"><label className="form-label">Mot de passe actuel</label><Input type="password" placeholder="••••••••" /></div>
              <div className="space-y-1.5"><label className="form-label">Nouveau mot de passe</label><Input type="password" placeholder="••••••••" /></div>
              <div className="space-y-1.5"><label className="form-label">Confirmer le nouveau mot de passe</label><Input type="password" placeholder="••••••••" /></div>
            </div>
            <Button onClick={() => toast.success('Mot de passe mis à jour')}><Save className="w-4 h-4" />Mettre à jour</Button>
          </div>
        </TabsContent>
      </Tabs>
    </div>
  )
}
