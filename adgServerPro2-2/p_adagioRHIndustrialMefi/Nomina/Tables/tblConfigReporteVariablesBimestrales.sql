USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblConfigReporteVariablesBimestrales](
	[IDConfiguracionVariablesbimestrales] [int] IDENTITY(1,1) NOT NULL,
	[ConceptosValesDespensa] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ConceptosPremioPuntualidad] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ConceptosPremioAsistencia] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ConceptosHorasExtrasDobles] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ConceptosIntegrablesVariables] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ConceptosDias] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDRazonMovimiento] [int] NOT NULL,
	[CriterioDias] [bit] NULL,
	[PromediarUMA] [int] NULL,
	[TopePremioPuntualidadAsistencia] [int] NULL,
 CONSTRAINT [PK_NominaTblConfigReporteVariablesBimestrales_IDConfiguracionVariablesbimestrales] PRIMARY KEY CLUSTERED 
(
	[IDConfiguracionVariablesbimestrales] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblConfigReporteVariablesBimestrales] ADD  DEFAULT ((0)) FOR [CriterioDias]
GO
ALTER TABLE [Nomina].[tblConfigReporteVariablesBimestrales] ADD  DEFAULT ((1)) FOR [TopePremioPuntualidadAsistencia]
GO
ALTER TABLE [Nomina].[tblConfigReporteVariablesBimestrales]  WITH CHECK ADD  CONSTRAINT [FK_IMSSTblCatRazonesMovAfiliatorios_NominaTblConfigReporteVariablesBimestrales_IDRazonMovimiento] FOREIGN KEY([IDRazonMovimiento])
REFERENCES [IMSS].[tblCatRazonesMovAfiliatorios] ([IDRazonMovimiento])
GO
ALTER TABLE [Nomina].[tblConfigReporteVariablesBimestrales] CHECK CONSTRAINT [FK_IMSSTblCatRazonesMovAfiliatorios_NominaTblConfigReporteVariablesBimestrales_IDRazonMovimiento]
GO
