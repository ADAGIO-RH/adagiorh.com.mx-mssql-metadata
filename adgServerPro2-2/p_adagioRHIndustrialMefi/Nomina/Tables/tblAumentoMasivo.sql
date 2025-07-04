USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblAumentoMasivo](
	[IDAumentoMasivo] [int] IDENTITY(1,1) NOT NULL,
	[Descripcion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Ejercicio] [int] NULL,
	[FechaCreacion] [datetime] NOT NULL,
	[IDTipoAumentoMasivo] [int] NOT NULL,
	[IDEstatusAumentoMasivo] [int] NOT NULL,
	[IDRazonMovimiento] [int] NULL,
	[FechaAplicacionMov] [datetime] NULL,
	[RespetarSalarioVariable] [bit] NOT NULL,
	[AfectaSalarioDiario] [bit] NOT NULL,
	[AfectaSalarioDiarioReal] [bit] NOT NULL,
	[ValorAumento] [decimal](18, 2) NULL,
	[IDUsuario] [int] NOT NULL,
 CONSTRAINT [Pk_NominatblAumentoMasivo_IDAumentoMasivo] PRIMARY KEY CLUSTERED 
(
	[IDAumentoMasivo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblAumentoMasivo] ADD  CONSTRAINT [D_NominaTblAumentoMasivo_FechaCreacion]  DEFAULT (getdate()) FOR [FechaCreacion]
GO
ALTER TABLE [Nomina].[tblAumentoMasivo] ADD  CONSTRAINT [D_NominaTblAumentoMasivo_RespetarSalarioVariable]  DEFAULT ((1)) FOR [RespetarSalarioVariable]
GO
ALTER TABLE [Nomina].[tblAumentoMasivo] ADD  CONSTRAINT [D_NominaTblAumentoMasivo_AfectaSalarioDiario]  DEFAULT ((1)) FOR [AfectaSalarioDiario]
GO
ALTER TABLE [Nomina].[tblAumentoMasivo] ADD  CONSTRAINT [D_NominaTblAumentoMasivo_AfectaSalarioDiarioReal]  DEFAULT ((0)) FOR [AfectaSalarioDiarioReal]
GO
ALTER TABLE [Nomina].[tblAumentoMasivo]  WITH CHECK ADD  CONSTRAINT [Fk_NominaTblAumentoMasivo_IMSStblCatRazonesMovAfiliatorios_IDRazonMovimiento] FOREIGN KEY([IDRazonMovimiento])
REFERENCES [IMSS].[tblCatRazonesMovAfiliatorios] ([IDRazonMovimiento])
GO
ALTER TABLE [Nomina].[tblAumentoMasivo] CHECK CONSTRAINT [Fk_NominaTblAumentoMasivo_IMSStblCatRazonesMovAfiliatorios_IDRazonMovimiento]
GO
ALTER TABLE [Nomina].[tblAumentoMasivo]  WITH CHECK ADD  CONSTRAINT [Fk_NominaTblAumentoMasivo_NominaTblCatEstatusAumentoMasivo_IDEstatusAumentoMasivo] FOREIGN KEY([IDEstatusAumentoMasivo])
REFERENCES [Nomina].[tblCatEstatusAumentoMasivo] ([IDEstatusAumentoMasivo])
GO
ALTER TABLE [Nomina].[tblAumentoMasivo] CHECK CONSTRAINT [Fk_NominaTblAumentoMasivo_NominaTblCatEstatusAumentoMasivo_IDEstatusAumentoMasivo]
GO
ALTER TABLE [Nomina].[tblAumentoMasivo]  WITH CHECK ADD  CONSTRAINT [Fk_NominaTblAumentoMasivo_NominaTblCatTipoAumentoMasivo_IDTipoAumentoMasivo] FOREIGN KEY([IDTipoAumentoMasivo])
REFERENCES [Nomina].[tblCatTipoAumentoMasivo] ([IDTipoAumentoMasivo])
GO
ALTER TABLE [Nomina].[tblAumentoMasivo] CHECK CONSTRAINT [Fk_NominaTblAumentoMasivo_NominaTblCatTipoAumentoMasivo_IDTipoAumentoMasivo]
GO
ALTER TABLE [Nomina].[tblAumentoMasivo]  WITH CHECK ADD  CONSTRAINT [Fk_NominaTblAumentoMasivo_SeguridadTblUsuarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Nomina].[tblAumentoMasivo] CHECK CONSTRAINT [Fk_NominaTblAumentoMasivo_SeguridadTblUsuarios_IDUsuario]
GO
