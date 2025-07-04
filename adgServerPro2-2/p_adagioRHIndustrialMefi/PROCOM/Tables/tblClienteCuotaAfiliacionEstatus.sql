USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PROCOM].[tblClienteCuotaAfiliacionEstatus](
	[IDClienteCuotaAfiliacionEstatus] [int] IDENTITY(1,1) NOT NULL,
	[IDClienteCuotaAfiliacion] [int] NOT NULL,
	[IDCatEstatusCuotaAfiliacion] [int] NOT NULL,
	[FechaHora] [datetime] NOT NULL,
 CONSTRAINT [PK_ProcomtblClienteCuotaAfiliacionEstatus_IDClienteCuotaAfiliacionEstatus] PRIMARY KEY CLUSTERED 
(
	[IDClienteCuotaAfiliacionEstatus] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [PROCOM].[tblClienteCuotaAfiliacionEstatus] ADD  CONSTRAINT [d_ProcomtblClienteCuotaAfiliacionEstatus_FechaHora]  DEFAULT (getdate()) FOR [FechaHora]
GO
ALTER TABLE [PROCOM].[tblClienteCuotaAfiliacionEstatus]  WITH CHECK ADD  CONSTRAINT [FK_ProcomTblCatEstatusCuotaAfiliacion_ProcomtblClienteCuotaAfiliacionEstatus_IDCatEstatusCuotaAfiliacion] FOREIGN KEY([IDCatEstatusCuotaAfiliacion])
REFERENCES [PROCOM].[tblCatEstatusCuotaAfiliacion] ([IDCatEstatusCuotaAfiliacion])
GO
ALTER TABLE [PROCOM].[tblClienteCuotaAfiliacionEstatus] CHECK CONSTRAINT [FK_ProcomTblCatEstatusCuotaAfiliacion_ProcomtblClienteCuotaAfiliacionEstatus_IDCatEstatusCuotaAfiliacion]
GO
ALTER TABLE [PROCOM].[tblClienteCuotaAfiliacionEstatus]  WITH CHECK ADD  CONSTRAINT [FK_ProcomtblClienteCuotaAfiliacion_ProcomtblClienteCuotaAfiliacionEstatus_IDClienteCuotaAfiliacion] FOREIGN KEY([IDClienteCuotaAfiliacion])
REFERENCES [PROCOM].[tblClienteCuotaAfiliacion] ([IDClienteCuotaAfiliacion])
GO
ALTER TABLE [PROCOM].[tblClienteCuotaAfiliacionEstatus] CHECK CONSTRAINT [FK_ProcomtblClienteCuotaAfiliacion_ProcomtblClienteCuotaAfiliacionEstatus_IDClienteCuotaAfiliacion]
GO
