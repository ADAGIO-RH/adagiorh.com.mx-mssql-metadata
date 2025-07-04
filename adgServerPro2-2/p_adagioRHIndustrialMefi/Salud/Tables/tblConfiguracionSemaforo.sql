USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Salud].[tblConfiguracionSemaforo](
	[IDConfiguracionSemaforo] [int] IDENTITY(1,1) NOT NULL,
	[IDCuestionario] [int] NOT NULL,
	[ValorInicio] [decimal](18, 2) NOT NULL,
	[ValorFinal] [decimal](18, 2) NOT NULL,
	[Color] [int] NULL,
 CONSTRAINT [Pk_SaludTblConfiguracionSemaforo_IDConfiguracionSemaforo] PRIMARY KEY CLUSTERED 
(
	[IDConfiguracionSemaforo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Salud].[tblConfiguracionSemaforo] ADD  CONSTRAINT [D_SaludTblConfiguracionSemaforo_ValorInicio]  DEFAULT ((0.0)) FOR [ValorInicio]
GO
ALTER TABLE [Salud].[tblConfiguracionSemaforo] ADD  CONSTRAINT [D_SaludTblConfiguracionSemaforo_ValorFinal]  DEFAULT ((0.0)) FOR [ValorFinal]
GO
ALTER TABLE [Salud].[tblConfiguracionSemaforo]  WITH CHECK ADD  CONSTRAINT [Fk_SaludTblConfiguracionSemaforo_SaludTblCuestionarios_IDCuestionario] FOREIGN KEY([IDCuestionario])
REFERENCES [Salud].[tblCuestionarios] ([IDCuestionario])
ON DELETE CASCADE
GO
ALTER TABLE [Salud].[tblConfiguracionSemaforo] CHECK CONSTRAINT [Fk_SaludTblConfiguracionSemaforo_SaludTblCuestionarios_IDCuestionario]
GO
